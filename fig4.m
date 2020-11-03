% c - 2D prediction on learning trial
% rt - RT on learning trial
% points - how many points subject was rewarded
% c_q - 2D reconstruction on query trial
% rt_q - RT on query trial
% s_q - objective stimulus shown on queried learning trial
% t_q - indices of queried learning trials
% The stimuli shown on each block are in opts.squares.


dirname = 'data1';

files = dir(dirname);
S = [];
B = [];
d_st = [];
d_en = [];
dpkf_d_st = [];
dpkf_d_en = [];
jump = [];
cond = [];

mynorm = @(x) sqrt(sum(x.^2, 2));

for idx = 1:length(files)
    if ~endsWith(files(idx).name, 'mat')
        continue;
    end

    filepath = fullfile(dirname, files(idx).name);
    filepath
    load(filepath);

    clear pred;
    clear recon;
    for b = 1:length(dat.block)

        Y = dat.opts.squares{b}.S; % stimuli

        [tr,i] = min(dat.block{b}.t_q); % smaller trial #

        first = Y(1,:);
        last = Y(end,:);
        d_st = [d_st; mynorm(dat.block{b}.c_q(i,:) - first)];
        d_en = [d_en; mynorm(dat.block{b}.c_q(i,:) - last)];
        B = [B; b];
        S = [S; dat.sub];
        jump = [jump; dat.opts.jump(b)];
        cond = [cond; dat.opts.cond(b)];

        res = dpks(Y);

        for t = 1:length(res)
            pred(t,:) = res(t).priorZ * res(t).x_pred; 
            recon(t,:) = res(t).pZ * res(t).x_smooth; 
        end

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
    end
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

