% old

% c - 2D prediction on learning trial
% rt - RT on learning trial
% points - how many points subject was rewarded
% c_q - 2D reconstruction on query trial
% rt_q - RT on query trial
% s_q - objective stimulus shown on queried learning trial
% t_q - indices of queried learning trials
% The stimuli shown on each block are in opts.squares.


data = load_data;

S = [];
B = [];
d_st = [];
d_en = [];
dpkf_d_st = [];
dpkf_d_en = [];
jump = [];
cond = [];

mynorm = @(x) sqrt(sum(x.^2, 2));

num_particles = 1000;

lmes = [];
models = {'MAP', 'ideal', 'sample'};

for s = 1:length(data)

    lme = [0 0 0];

    s

    clear pred;
    clear recon;
    ll = 0;
    for b = 1:length(data(s).block)

        b

        Y = data(s).opts.squares{b}.S; % stimuli
        a = data(s).block{b}.c; % choices (predictions)

        opts = dpkf_opts(Y);

        [tr,i] = min(data(s).block{b}.t_q); % smaller trial #

        first = Y(1,:);
        last = Y(end,:);
        d_st = [d_st; mynorm(data(s).block{b}.c_q(i,:) - first)];
        d_en = [d_en; mynorm(data(s).block{b}.c_q(i,:) - last)];
        B = [B; b];
        S = [S; data(s).sub];
        jump = [jump; data(s).opts.jump(b)];
        cond = [cond; data(s).opts.cond(b)];

        %Y = Y(1:3,:);

        % run it manually
        %
        res = dpks(Y, opts);

        clear pred;
        clear recon;
        clear lik;
        for t = 1:length(res)
            pred(t,:) = res(t).priorZ * res(t).x_pred; 
            recon(t,:) = res(t).pZ * res(t).x_smooth; 
            out(t,:) = res(t).priorZ * res(t).x_pred;
            lik(t) = mvnpdf(a(t,:), res(t).priorZ * res(t).x_pred, opts.V);
        end
        loglik = sum(log(lik));
        ll = ll + loglik;

        %{
        figure;
        hold on;
        plot(Y(:,2));
        plot(pred(:,2));
        plot(recon(:,2));
        legend({'stimulus', 'prediction', 'reconstruction'});
        %}

        dpkf_d_st = [dpkf_d_st; mynorm(recon(tr,:) - first)];
        dpkf_d_en = [dpkf_d_en; mynorm(recon(tr,:) - last)];

        %disp('snthaeu');

        % MAP particle
        %
        T = size(Y,1);
        init_fn = @() dpkf_init(Y, opts);
        choice_fn = @(t, particle) dpkf_choice(t, particle, a, opts);
        update_fn = @(t, particle) dpkf_MAP_update(t, particle, Y, opts);
        [results1, particles1] = forward(T, 1, init_fn, choice_fn, update_fn, true);
        loglik1 = sum(log(results1.liks));

        assert(immse(loglik1, loglik) < 1e-9);

        lme(1) = lme(1) + loglik1;

        % ideal 
        %
        init_fn = @() dpkf_init(Y, opts);
        choice_fn = @(t, particle) dpkf_choice(t, particle, a, opts);
        update_fn = @(t, particle) dpkf_sample_update(t, particle, Y, opts);
        [results2, particles2] = forward(T, num_particles, init_fn, choice_fn, update_fn, false);
        loglik2 = sum(log(results2.liks));

        lme(2) = lme(2) + loglik2;

        % sample
        %
        init_fn = @() dpkf_init(Y, opts);
        choice_fn = @(t, particle) dpkf_choice(t, particle, a, opts);
        update_fn = @(t, particle) dpkf_sample_update(t, particle, Y, opts);
        [results3, particles3] = forward(T, num_particles, init_fn, choice_fn, update_fn, true);
        loglik3 = sum(log(results3.liks));

        lme(3) = lme(3) + loglik3;
    end

    loglik = dpkf_loglik([1 0.01 50 0.1 0 1], data(s));
    assert(immse(loglik, ll) < 1e-9);


    lmes = [lmes; lme];
end

T = table(S, B, jump, cond, d_st, d_en, dpkf_d_st, dpkf_d_en);

ms = [mean(T.d_st(T.jump == 1)) mean(T.d_st(T.jump == 0));
      mean(T.d_en(T.jump == 1)) mean(T.d_en(T.jump == 0))];

dpkf_ms = [mean(T.dpkf_d_st(T.jump == 1)) mean(T.dpkf_d_st(T.jump == 0));
           mean(T.dpkf_d_en(T.jump == 1)) mean(T.dpkf_d_en(T.jump == 0))];

figure;
subplot(2,1,1);
h = bar(ms);
xticklabels({'start', 'end'});
legend({'gradual', 'jump'});
title('humans');

subplot(2,1,2);
h = bar(dpkf_ms);
xticklabels({'start', 'end'});
legend({'gradual', 'jump'});
title('DP-KF');


[alpha,exp_r,xp,pxp,bor] = bms(lmes);

pxp
bor

save('fig4.mat');
