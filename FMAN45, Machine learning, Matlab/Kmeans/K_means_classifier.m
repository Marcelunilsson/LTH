function [y_pred, Cx] = K_means_classifier(X,C, labels)
    y_pred = zeros(1, size(X, 2));
    Cx = zeros(1, size(X, 2));
    for i = 1:length(y_pred)
        d = fx_dist(X(:, i), C);
        y_pred(i) = labels(d == min(d));
        Cx(i) = find(d==min(d));
    end
end

function d = fx_dist(x,C)
    d = sqrt(sum((x - C) .^ 2));
end