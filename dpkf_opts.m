function opts = dpkf_opts(Y, opts)

    [T,D] = size(Y);

    % set missing parameters to their defaults
    def_opts.Q = 0.01;
    def_opts.W = 1;
    def_opts.R = 1;
    def_opts.C = 10;
    def_opts.alpha = 0.1;
    def_opts.sticky = 0;
    def_opts.x0 = zeros(1,D);
    def_opts.Kmax = 10;
    F = fieldnames(def_opts);
    if nargin < 2 || isempty(opts)
        opts = def_opts;
    else
        for i = 1:length(F); if ~isfield(opts,F{i}); opts.(F{i}) = def_opts.(F{i}); end; end
    end
    
    % if scalar parameters are given, assume these are the same for all dimensions
    if isscalar(opts.x0); opts.x0 = zeros(1,D)+opts.x0; end
    if isscalar(opts.Q); opts.Q = diag(zeros(1,D)+opts.Q); end
    if isscalar(opts.W); opts.W = diag(zeros(1,D)+opts.W); end
    if isscalar(opts.R); opts.R = diag(zeros(1,D)+opts.R); end
    if isscalar(opts.C); opts.C = diag(zeros(1,D)+opts.C); end
