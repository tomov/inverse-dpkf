%function [results, bms_results, data] = fit_models()

    clear all;

    models = {'stationary_kf', 'kf', 'stationary_dpkf', 'dpkf'};
    models = models(4);

    data = load_data();

    for m = 1:length(models)

        disp(['... fitting model ',num2str(m)]);

        %{
        param(1) = struct('name','r','logpdf',@(x) 0,'lb', 0.001,'ub', 20);
        param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0.001,'ub', 30);
        param(3) = struct('name','v','logpdf',@(x) 0,'lb', 10,'ub', 20); % TODO sig in dpkf_lik.m ?
        param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0.001,'ub', 10);
        param(5) = struct('name','sticky','logpdf',@(x) 0,'lb', 0.001,'ub', 10);
        param(6) = struct('name','w','logpdf',@(x) 0,'lb', 0.001,'ub', 1);
        %}

        %{
        param(1) = struct('name','r','logpdf',@(x) 0,'lb', 0.5,'ub', 2);
        param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0.005,'ub', 0.02);
        param(3) = struct('name','v','logpdf',@(x) 0,'lb', 30,'ub', 60); % TODO sig in dpkf_lik.m ?
        param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0.05,'ub', 0.2);
        param(5) = struct('name','sticky','logpdf',@(x) 0,'lb', 0.001,'ub', 1);
        param(6) = struct('name','w','logpdf',@(x) 0,'lb', 0.9,'ub', 1);
        %}

        param(1) = struct('name','r','logpdf',@(x) 0,'lb', 0.01,'ub', 10);
        param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0.001,'ub', 10);
        param(3) = struct('name','v','logpdf',@(x) 0,'lb', 30,'ub', 1000); % TODO sig in dpkf_lik.m ?
        param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0.0001,'ub', 5);
        param(5) = struct('name','sticky','logpdf',@(x) 0,'lb', 0.0001,'ub', 10);
        param(6) = struct('name','w','logpdf',@(x) 0,'lb', 0.9,'ub', 1.1);

        switch models{m}
            % clamp parameters

            case 'stationary_kf'
                param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0,'ub', 0);
                param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0,'ub', 0);

            case 'kf'
                param(4) = struct('name','alpha','logpdf',@(x) 0,'lb', 0,'ub', 0);

            case 'stationary_dpkf'
                param(2) = struct('name','q','logpdf',@(x) 0,'lb', 0,'ub', 0);

            case 'dpkf'

            otherwise
                assert(false)
        end

        %fun = str2func(likfuns{m});
        fun = @dpkf_loglik;
        results(m) = mfit_optimize(fun,param,data);
        results(m).model_name = models{m};
        clear param
    end

    bms_results = mfit_bms(results, 1);  % use BIC TODO try 0

    %save('fit_models_4_narrow.mat');
    %save('fit_models_4_narrower.mat');
    save('fit_models_4_c.mat');
    bms_results.pxp
    bms_results.bor

