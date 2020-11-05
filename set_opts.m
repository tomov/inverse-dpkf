function opts = set_opts(Y, x)

    opts.R = x(1);
    opts.Q = x(2);
    opts.V = x(3);
    opts.alpha = x(4);
    opts.sticky = x(5);
    opts.W = x(6);

    %opts.C = 1000;

    opts = dpkf_opts(Y, opts);
    %opts = dpkf_opts(Y);


