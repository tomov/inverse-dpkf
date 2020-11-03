
dirname = 'data1';

files = dir(dirname);
S = [];
B = [];
d_st = [];
d_en = [];
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

    for b = 1:length(dat.block)

        Y = dat.opts.squares{b}.S; % stimuli

        first = Y(1,:);
        last = Y(end,:);
        d_st = [d_st; mynorm(dat.block{b}.c_q - first)];
        d_en = [d_en; mynorm(dat.block{b}.c_q - last)];
        B = [B; ones(size(dat.block{b}.c_q, 1), 1) * b];
        S = [S; ones(size(dat.block{b}.c_q, 1), 1) * dat.sub];
        jump = [jump; ones(size(dat.block{b}.c_q, 1), 1) * dat.opts.jump(b)];
        cond = [cond; ones(size(dat.block{b}.c_q, 1), 1) * dat.opts.cond(b)];

        res = dpkf(Y);

        for t = 1:size(Y,1)
        end

        snahteu
    end
end

T = table(S, B, jump, cond, d_st, d_en);

ms = [mean(T.d_st(T.jump == 1)) mean(T.d_st(T.jump == 0));
      mean(T.d_en(T.jump == 1)) mean(T.d_en(T.jump == 0))];

figure;
h = bar(ms);
