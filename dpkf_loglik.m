function loglik = dpkf_loglik(x, data)

    opts.R = x(1);
    opts.Q = x(2);
    opts.V = x(3);
    opts.alpha = x(4);
    opts.sticky = x(5);
    opts.W = x(6);

    opts.C = 1000;

    opts = dpkf_opts(data.opts.squares{1}, opts);

    loglik = 0;

    for b = 1:length(data.block)

        Y = data.opts.squares{b}.S; % stimuli
        a = data.block{b}.c; % choices (predictions)

        opts = dpkf_opts(Y);

        res = dpks(Y, opts);

        lik = zeros(1, length(res));
        for t = 1:length(res)
            lik(t) = mvnpdf(a(t,:), res(t).priorZ * res(t).x_pred, opts.V);
        end
        loglik = loglik + sum(log(lik));
    end

