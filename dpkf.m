function [results, opts] = dpkf(Y,opts)
    
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
    
    % initialization
    for k = 1:opts.Kmax
        P{k} = opts.C;
        x(k,:) = opts.x0;
    end
    pZ = [1 zeros(1,opts.Kmax-1)];  % mode 1 starts with probability 1
    khat = 1;
    M = [1 zeros(1,opts.Kmax-1)];
    lik = zeros(1,opts.Kmax);
    
    % run DPKF
    for t = 1:T
        
        x = x*opts.W;           % predicted (a priori) estimate
        yhat = pZ*x;
        err = Y(t,:) - yhat;    % prediction error
        for k = 1:opts.Kmax
            % TODO momchil transposes flipped? b/c row vectors?
            P{k} = opts.W*P{k}*opts.W' + opts.Q;    % predicted (a priori) estimate covariance
        end

        results(t).x_pred = x;
        results(t).P_pred = P;
        results(t).priorZ = pZ;
        
        if all(~isnan(err))
            
            % compute posterior over modes
            if t > 1 && opts.alpha > 0
                
                % Chinese restaurant prior
                prior = M;
                knew = find(prior==0,1);
                prior(knew) = opts.alpha;   % probability of new mode
                prior(khat) = prior(khat) + opts.sticky;      % make last mode sticky
                prior = prior./sum(prior);

                % multivariate Gaussian likelihood
                for k = 1:opts.Kmax
                    lik(k) = mvnpdf(Y(t,:),x(k,:),P{k}+opts.R);
                end
                
                % posterior
                pZ = prior.*lik;
                pZ = pZ./sum(pZ);
                if isnan(pZ(1)) % TODO momchil ask Sam -- liks = 0; variance too tight
                    % if we get "impossible" observation, set new mode to it
                    pZ(:) = 0;
                    pZ(knew) = 1;
                    x(knew,:) = Y(t,:);
                    err = zeros(size(x(knew,:))); % hack
                    err
                end
                
                % MAP estimate
                [~,khat] = max(pZ);
                M(khat) = M(khat) + 1;
            end
            
            % update estimates
            for k = 1:opts.Kmax
                S{k} = (pZ(k)^2)*P{k} + opts.R;         % error covariance
                G{k} = (P{k}*pZ(k))/S{k};               % Kalman gain
                x(k,:) = x(k,:) + err*G{k};             % updated (a posteriori) estimate
                P{k} = P{k} - pZ(k)*G{k}*P{k};          % updated (a posteriori) estimate covariance
            end
        end
        
        % store results
        results(t).P = P;
        results(t).x = x;
        results(t).G = G;
        results(t).pZ = pZ;
        results(t).err = err;
        
    end
