function [particle] = dpkf(t,particle,Y,opts)
    
    % Dirichlet process Kalman filter algorithm. Uses a local maximum a
    % posteriori estimate of the partition.
    % from https://github.com/sjgershm/gershmanlab/blob/master/models/dpkf.m
    %
    % USAGE: results = dpkf(Y,[opts])
    %
    % INPUTS:
    %   Y - [T x D] observation sequence, where Y(t,d) is dimension d of the observation at time t
    %   opts (optional) - structure with any of the following fields
    %                     (missing fields are set to defaults):
    %                       .R = noise covariance (default: eye(D))
    %                       .Q = diffusion covariance (default: 0.01*eye(D))
    %                       .W = dynamics matrix (default: eye(D))
    %                       .C = prior state covariance (default: 10*eye(D))
    %                       .alpha = concentration parameter (default: 0.1)
    %                       .sticky = stickiness of last mode (default: 0)
    %                       .x0 = prior mean (default: zeros(1,D))
    %                       .Kmax = upper bound on number of state (default: 10)
    %                   Note: if R, Q, W, or C are given as scalars, it is
    %                         assumed that they are the same for all dimensions
    %
    % OUTPUTS:
    %   results - [1 x T] structure with the following fields:
    %             .P = [1 x Kmax] cell array of [D x D] posterior
    %                  covariance matrices (one for each mode)
    %             .x - [K x D] matrix of posterior mean state estimates
    %             .G - [1 x Kmax] cell array of [D x D] Kalman gain
    %             .err - [1 x D] prediction error vector
    %             .pZ - [1 x K] posterior probability of modes
    %
    % Sam Gershman, June 2015
    % Reference: Gershman, Radulescu, Norman & Niv (2014). Statistical
    % computations underlying the dynamics of memory updating. PLOS
    % Computational Biology.
    
    [T,D] = size(Y);
    
    if ~exist('opts', 'var')
        opts = dpkf_opts(Y);
    else
        opts = dpkf_opts(Y, opts);
    end
    
        
        x = particle.x*opts.W;           % predicted (a priori) estimate
        yhat = particle.pZ*x;
        err = Y(t,:) - yhat;    % prediction error
        for k = 1:opts.Kmax
            % TODO momchil transposes flipped? b/c row vectors?
            P{k} = opts.W*particle.P{k}*opts.W' + opts.Q;    % predicted (a priori) estimate covariance
        end

        particle.results(t).x_pred = x;
        particle.results(t).P_pred = P;
        particle.results(t).priorZ = particle.pZ;
        
        if all(~isnan(err))
            
            % compute posterior over modes
            if t > 1 && opts.alpha > 0
                
                % Chinese restaurant prior
                prior = particle.M;
                prior(find(prior==0,1)) = opts.alpha;   % probability of new mode
                prior(particle.khat) = prior(particle.khat) + opts.sticky;      % make last mode sticky
                prior = prior./sum(prior);
                
                % multivariate Gaussian likelihood
                for k = 1:opts.Kmax
                    particle.lik(k) = mvnpdf(Y(t,:),x(k,:),P{k}+opts.R);
                end
                
                % posterior
                particle.pZ = prior.*particle.lik;
                particle.pZ = particle.pZ./sum(particle.pZ);
                if isnan(particle.pZ(1)) % TODO momchil ask Sam -- liks = 0; variance too tight
                    particle.pZ = prior;
                end
                
                % MAP estimate
                %[~,particle.khat] = max(particle.pZ);
                % sample estimate
                particle.khat = randsample(opts.Kmax, 1, true, particle.pZ);

                particle.M(particle.khat) = particle.M(particle.khat) + 1;
            end
            
            % update estimates
            for k = 1:opts.Kmax
                S{k} = (particle.pZ(k)^2)*P{k} + opts.R;         % error covariance
                G{k} = (P{k}*particle.pZ(k))/S{k};               % Kalman gain
                particle.x(k,:) = x(k,:) + err*G{k};             % updated (a posteriori) estimate
                particle.P{k} = P{k} - particle.pZ(k)*G{k}*P{k};          % updated (a posteriori) estimate covariance
            end
        end
        
        % store results
        particle.results(t).P = particle.P;
        particle.results(t).x = particle.x;
        particle.results(t).G = G;
        particle.results(t).pZ = particle.pZ;
        particle.results(t).err = err;
       

