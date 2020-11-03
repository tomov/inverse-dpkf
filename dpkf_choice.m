function [lik, out] = dpkf_choice(t,particle,a,opts)
    
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
    
    [T,D] = size(a);
  
    if ~exist('opts', 'var')
        opts = dpkf_opts(a);
    else
        opts = dpkf_opts(a, opts);
    end
    
        x = particle.x*opts.W;           % predicted (a priori) estimate

        out = particle.pZ * x;

        lik = mvnpdf(a(t,:), out, opts.V);

