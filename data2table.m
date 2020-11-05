function T = data2table(data, param)

if size(param,1) == 1
    param = repmat(param, length(data), 1);
end
    
S = [];
B = [];
human_d_st = [];
human_d_en = [];
model_d_st = [];
model_d_en = [];
jump = [];
cond = [];

mynorm = @(x) sqrt(sum(x.^2, 2));

for s = 1:length(data)

    clear pred;
    clear recon;
    ll = 0;
    for b = 1:length(data(s).block)

        Y = data(s).opts.squares{b}.S; % stimuli
        a = data(s).block{b}.c; % choices (predictions)

        opts = set_opts(Y, param(s,:));

        [tr,i] = min(data(s).block{b}.t_q); % smaller trial #

        first = Y(1,:);
        last = Y(end,:);
        human_d_st = [human_d_st; mynorm(data(s).block{b}.c_q(i,:) - first)];
        human_d_en = [human_d_en; mynorm(data(s).block{b}.c_q(i,:) - last)];
        B = [B; b];
        %S = [S; data(s).sub];
        S = [S; s];
        jump = [jump; data(s).opts.jump(b)];
        cond = [cond; data(s).opts.cond(b)];

        % run it manually
        %
        res = dpks(Y, opts);

        clear pred;
        clear recon;
        clear lik;
        for t = 1:length(res)
            pred(t,:) = res(t).priorZ * res(t).x_pred; 
            recon(t,:) = res(t).pZ * res(t).x_smooth; 
        %    out(t,:) = res(t).priorZ * res(t).x_pred;
        %    lik(t) = mvnpdf(a(t,:), res(t).priorZ * res(t).x_pred, opts.V);
        end
        %loglik = sum(log(lik));
        %ll = ll + loglik;

        model_d_st = [model_d_st; mynorm(recon(tr,:) - first)];
        model_d_en = [model_d_en; mynorm(recon(tr,:) - last)];
    end

end

T = table(S, B, jump, cond, human_d_st, human_d_en, model_d_st, model_d_en);

