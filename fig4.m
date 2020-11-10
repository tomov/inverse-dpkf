% c - 2D prediction on learning trial
% rt - RT on learning trial
% points - how many points subject was rewarded
% c_q - 2D reconstruction on query trial
% rt_q - RT on query trial
% s_q - objective stimulus shown on queried learning trial
% t_q - indices of queried learning trials
% The stimuli shown on each block are in opts.squares.


data = load_data;

%load('fit_models.mat');

figure;

% r q v alpha sticky w 
default_params = [1 0.01 50 0.1 0 1];
params = {[1 0 50 0 0 1], 
          [1 0.01 50 0 0 1],
          [1 0 50 0.1 0 1],
          [1 0.01 50 0.1 0 1]};

params = [1 0.01 10 0.1 0 1];

for m = 1:length(results)

    %T = data2table(data, params);
    %T = data2table(data, params{4});
    T = data2table(data, results(1).x);

    [human_sems human_ms X] = wse_helper(data, T, 'human_d_st', 'human_d_en');

    [model_sems model_ms X] = wse_helper(data, T, 'model_d_st', 'model_d_en');

    if m == 1
        subplot(2,length(results),1);
        h = bar([human_ms(1:2); human_ms(3:4)]);
        xs = sort([h(1).XData + h(1).XOffset, ...
                   h(2).XData + h(2).XOffset]);
        hold on;
        errorbar(xs, human_ms, human_sems, '.', 'MarkerSize', 1, 'MarkerFaceColor', [0 0 0], 'LineWidth', 1, 'Color', [0 0 0], 'AlignVertexCenters', 'off');
        xticklabels({'start', 'end'});
        legend({'gradual', 'jump'});
        title('humans');
    end

    subplot(2,length(results), m + length(results));
    h = bar([model_ms(1:2); model_ms(3:4)]);
    xs = sort([h(1).XData + h(1).XOffset, ...
               h(2).XData + h(2).XOffset]);
    hold on;
    errorbar(xs, model_ms, model_sems, '.', 'MarkerSize', 1, 'MarkerFaceColor', [0 0 0], 'LineWidth', 1, 'Color', [0 0 0], 'AlignVertexCenters', 'off');
    xticklabels({'start', 'end'});
    title(models{m}, 'interprete', 'none');

end

save('fig4.mat');


function [se, m, X] = wse_helper(data, T, st, en)

    X = [];
    for s = 1:length(data)
        m = [mean(T.(st)(T.jump == 1 & T.S == s)); ...
             mean(T.(st)(T.jump == 0 & T.S == s)); ...
             mean(T.(en)(T.jump == 1 & T.S == s)); ...
             mean(T.(en)(T.jump == 0 & T.S == s))];
        X = [X m];
    end

    [se, m] = wse(X');
end

