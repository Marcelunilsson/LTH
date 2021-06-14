function w_hat = lasso_ccd(t,X,lambda,w_old)
% what = lasso_ccd(t,X,lambda,wold)
% Solves the LASSO optimization problem using cyclic coordinate descent.
%
%   Output: 
%    what   - Mx1 LASSO estimate using cyclic coordinate descent algorithm
%
%   inputs: 
%   t       - Nx1 data column vector
%   X       - NxM regression matrix
%   lambda  - 1x1 hyperparameter value
%   (optional)
%   wold    - Mx1 lasso estimate used for warm-starting the solution.

% Check for match between t and X
[N,M] = size(X);
if size(t,1) ~= N
    disp('Sizes in t and X do not match!')
    w_hat = [];
    return
end

if nargin < 4
    w_old = zeros(M,1); % set wold to zeros if warm-start is unavailable
end

% Optimization variables and preallocation
N_iter = 50; % number of iterations
updatecycle = 5; % at which intensity all variables should be updated.
zero_tol = lambda; % what is to be considered equal to zero in support.
w = w_old; % set intial w to wold from previous lasso estimate, if available
w_sup = double(abs(w)>zero_tol); % defines the non-zero indices of w

r = t - X*w; % calculate residual and use it instead of y-Xw with proper indexing.

w_last_iter= 0;
for k_iter = 1:N_iter
    
    % Snippet below is a common way of speeding up the estimation process. Use it
    % if you like. Basically, only the non-zero estimates are updated
    % at every iteration. The zero estimates are only updated every
    % updatecycle number of iterations. Use to your liking. Otherwise use
    % contents of else statement.
    if rem(k_iter,updatecycle) && k_iter>2
        k_ind_nonzero = find(w_sup);
        rand_ind = randperm(length(k_ind_nonzero));
        k_ind_vec_random = k_ind_nonzero(rand_ind);
    else
        k_ind_vec = 1:M;
        k_ind_vec_random = k_ind_vec(randperm(length(k_ind_vec)));
    end
    
    % sweep over coordinates, in randomized order defined by kInd_random
    for k_sweep = 1:length(k_ind_vec_random)
        k_ind = k_ind_vec_random(k_sweep); % Pick out current coordinate to modify.
        
        x = X(:, k_ind);
        r = r + x*w(k_ind);
        %r = t-sum([X(:, 1:k_ind-1)*diag(w(1:k_ind-1))]')' - sum([X(:, k_ind+1:end)*diag(w(k_ind+1:end))]')';
        w(k_ind) = (x'*r / ((x'*x)*abs(x'*r))*(abs(x'*r)-lambda)) * (abs(x'*r) > lambda);
        r = r-x*w(k_ind); 
        
        w_sup(k_ind) = double(abs(w(k_ind))>zero_tol); % update whether w(kind) is zero or not.
    end
    %if sum((w-w_last_iter).^2) < 1E-3
    %    break
    %end
    %w_last_iter = w;
end

w_hat = w; % assign function output.
end
