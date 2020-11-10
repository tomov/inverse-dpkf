function loglik = dpkf_loglik(x, data)

    opts = set_opts(data.opts.squares{1}, x);

    loglik = 0;

    for b = 1:length(data.block)

        Y = data.opts.squares{b}.S; % stimuli
        a = data.block{b}.c; % choices (predictions)

        %opts = dpkf_opts(Y);
        opts = set_opts(Y, x);

        res = dpks(Y, opts);

        lik = zeros(1, length(res));
        for t = 1:length(res)
            lik(t) = mvnpdf(a(t,:), res(t).priorZ * res(t).x_pred, opts.V);
        end
        loglik = loglik + sum(log(lik));
    end

    loglik
