function [y,C] = K_means_clustering(X,K)

% Calculating cluster centroids and cluster assignments for:
% Input:    X   DxN matrix of input data
%           K   Number of clusters
%
% Output:   y   Nx1 vector of cluster assignments
%           C   DxK matrix of cluster centroids

[D,N] = size(X);

inter_max = 50;
conv_tol = 1e-6;
% Initialize
C = repmat(mean(X,2),1,K) + repmat(std(X,[],2),1,K).*randn(D,K);
y = zeros(N,1);
C_old = C;

for k_iter = 1:inter_max

    % Step 1: Assign to clusters
    y = step_assign_cluster(X, C, y);
    
    % Step 2: Assign new clusters
    [C, deltaC] = step_compute_mean(X, y, C_old);
        
    if deltaC < conv_tol
        return;
    end
    C_old = C;
end

end

function d = fx_dist(x,C)
    d = sqrt(sum((x - C) .^ 2));
end

function d = fc_dist(C1,C2)
    d = sqrt(sum((C1 - C2) .^ 2));
end

function y = step_assign_cluster(X, C, y)
    for i = 1:size(X, 2)
        d = fx_dist(X(:, i), C);
        y(i) =  find(d == min(d));
    end
end

function [C, deltaC] = step_compute_mean(X, y, C_old)
    for i = 1:size(C_old, 2)
        C(:,i) = mean(X(:,y == i), 2);
    end
    deltaC = fc_dist(C, C_old);
end

%%

