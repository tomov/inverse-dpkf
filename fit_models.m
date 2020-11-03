function [results, bms_results, data] = fit_models()

    models = {'stationary_kf', 'kf', 'stationary_dpkf', 'dpkf'};

    for m = 1:length(models)

        disp(['... fitting model ',num2str(m)]);

        param(1) = struct('name','r','logpdf',@(x) 0,'lb', 0.001,'ub', 20);
        param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0.001,'ub', 30);
        param(3) = struct('name','v','logpdf',@(x) 0,'lb', 0.001,'ub', 10);
        param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0.001,'ub', 10);
        param(5) = struct('name','sticky','logpdf',@(x) 0,'lb', 0.001,'ub', 10);
        param(6) = struct('name','w','logpdf',@(x) 0,'lb', 0.001,'ub', 10);

        switch models{m}
            % clamp parameters

            case 'stationary_kf'
                param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0,'ub', 0);
                param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0,'ub', 0);

            case 'kf'
                param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0,'ub', 0);

            case 'stationary_dpkf'
                param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0,'ub', 0);

            otherwise
                assert(false)
        end

        %fun = str2func(likfuns{m});
        fun = @dpkf_loglik;
        results(m) = mfit_optimize(fun,param,data);
        clear param
    end

    bms_results = mfit_bms(results, 1);  % use BIC TODO try 0
