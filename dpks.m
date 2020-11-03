function results = dpks(Y,opts)

    % Dirichlet process Kalman smoothing algorithm.
    %

    if ~exist('opts', 'var')
        [results, opts] = dpkf(Y);
    else
        [results, opts] = dpkf(Y, opts);
    end

    Kmax = size(results(1).x,1);

    x_smooth = results(end).x;
    results(end).x_smooth = x_smooth;

    % Rauch-Tung-Striebel
    for t = length(results)-1:-1:1
        for k = 1:Kmax
            % note flipped order b/c everything is transposed, and W not transposed
            C = results(t+1).P_pred{k} \ opts.W * results(t).P{k};
            x_smooth(k,:) = results(t).x(k,:) + (x_smooth(k,:) - results(t+1).x_pred(k,:)) * C;
        end
        results(t).x_smooth = x_smooth;
    end

