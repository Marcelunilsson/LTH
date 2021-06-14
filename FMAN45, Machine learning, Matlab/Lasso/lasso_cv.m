function [w_opt,lambda_opt,RMSE_val,RMSE_est] = lasso_cv(t,X,lambda_vec,K)
% [wopt,lambdaopt,VMSE,EMSE] = lasso_cv(t,X,lambdavec)
% Calculates the LASSO solution problem and trains the hyperparameter using
% cross-validation.
%
%   Output: 
%   wopt        - mx1 LASSO estimate for optimal lambda
%   lambdaopt   - optimal lambda value
%   MSEval      - vector of validation MSE values for lambdas in grid
%   MSEest      - vector of estimation MSE values for lambdas in grid
%
%   inputs: 
%   y           - nx1 data column vector
%   X           - nxm regression matrix
%   lambdavec   - vector grid of possible hyperparameters
%   K           - number of folds

[N,M] = size(X);
N_lam = length(lambda_vec);

% Preallocate
SE_val = zeros(K,N_lam);
SE_est = zeros(K,N_lam);


% cross-validation indexing
random_ind = randperm(N); % Select random indices for validation and estimation
location = 0; % Index start when moving through the folds
N_val = floor(N/K); % How many samples per fold
hop = N_val; % How many samples to skip when moving to the next fold.
fold = 1:N_val;

for k_fold = 1:K
   
    %val_ind = random_ind((k_fold - 1)*N_val +1:k_fold*N_val); % Select validation indices
    %est_ind = setdiff(random_ind, val_ind); % Select estimation indices
    val_ind = random_ind(location + fold); % Select validation indices
    est_ind = random_ind([1:location,location + hop + 1:end]); % Select estimation indices
    
    assert(isempty(intersect(val_ind,est_ind)), "There are overlapping indices in valind and estind!"); % assert empty intersection between valind and estind
    w_old = zeros(M,1); % Initialize estimate for warm-starting.
    
    for k_lam = 1:N_lam
        
        w_hat = lasso_ccd(t(est_ind), X(est_ind, :), lambda_vec(k_lam), w_old); % Calculate LASSO estimate on estimation indices for the current lambda-value.
        
        SE_val(k_fold,k_lam) = sqrt((1/N_val)*sum(t(val_ind)-X(val_ind, :)*w_hat).^2); % Calculate validation error for this estimate
        SE_est(k_fold,k_lam) = sqrt((1/(N-N_val))*sum(t(est_ind)-X(est_ind, :)*w_hat).^2); % Calculate estimation error for this estimate
        
        w_old = w_hat; % Set current estimate as old estimate for next lambda-value.
        %disp(['Fold: ' num2str(k_fold) ', lambda-index: ' num2str(k_lam)]); % Display current fold and lambda-index.
        
    end
    disp(['Fold: ' num2str(k_fold)])
    location = location+hop; % Hop to location for next fold.
end


MSE_val = mean(SE_val,1); % Calculate MSE_val as mean of validation error over the folds.
MSE_est = mean(SE_est,1); % Calculate MSE_est as mean of estimation error over the folds.
lambda_opt = lambda_vec(MSE_val == min(MSE_val)); % Select optimal lambda 


RMSE_val = sqrt(MSE_val);
RMSE_est = sqrt(MSE_est);


w_opt = lasso_ccd(t, X, lambda_opt); % Calculate LASSO estimate for selected lambda using all data.
disp("Done")
end

