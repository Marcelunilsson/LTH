function [W_opt,lambda_opt,RMSE_val,RMSE_est] = multiframe_lasso_cv(T,X,lambda_vec,K)
% [wopt,lambdaopt,VMSE,EMSE] = multiframe_lasso_cv(T,X,lambdavec,n)
% Calculates the LASSO solution for all frames and trains the
% hyperparameter using cross-validation.
%
%   Output:
%   Wopt        - mxnframes LASSO estimate for optimal lambda
%   lambdaopt   - optimal lambda value
%   VMSE        - vector of validation MSE values for lambdas in grid
%   EMSE        - vector of estimation MSE values for lambdas in grid
%
%   inputs:
%   T           - NNx1 data column vector
%   X           - NxM regression matrix
%   lambdavec   - vector grid of possible hyperparameters
%   K           - number of folds

% Define some sizes
NN = length(T);
[N,M] = size(X);
N_lam = length(lambda_vec);

% Set indexing parameters for moving through the frames.
frame_hop = N;
idx = (1:N)';
frame_location = 0;
N_frames = 0;
while frame_location + N <= NN
    N_frames = N_frames + 1; 
    frame_location = frame_location + frame_hop;
end % Calculate number of frames.

% Preallocate
W_opt = zeros(M,N_frames);
SE_val = zeros(K,N_lam);
SE_est = zeros(K,N_lam);

% Set indexing parameter for the cross-validation indexing
N_val = floor(N/K);
cvhop = N_val;
random_ind = randperm(N);% Select random indices for picking out validation and estimation indices. 
    
frame_location = 0;
for k_frame = 1:N_frames % First loop over frames
    
    cv_location = 0;
    
    for k_fold = 1:K % Then loop over the folds
        
        val_ind = random_ind((k_fold - 1)*N_val +1:k_fold*N_val); % Select validation indices
        est_ind = setdiff(random_ind, val_ind); % Select estimation indices
                
        assert(isempty(intersect(val_ind,est_ind)), "There are overlapping indices in valind and estind!"); % assert empty intersection between valind and estind
    
        
        t = T(frame_location + idx); % Set data in this frame
        w_old = zeros(M,1);  % Initialize old weights for warm-starting.
        
        for k_lam = 1:N_lam  % Finally loop over the lambda grid
            
            w_hat = lasso_ccd(t(est_ind), X(est_ind, :), lambda_vec(k_lam));% Calculate LASSO estimate at current frame, fold, and lambda
            
            SE_val(k_fold,k_lam) = (1/N_val)*norm(t(val_ind)-X(val_ind, :)*w_hat)^2; % Add validation error at current frame, fold and lambda to the validation error for this fold and lambda, summing tthe error over the frames
            SE_est(k_fold,k_lam) = (1/N_val)*norm(t(est_ind)-X(est_ind, :)*w_hat)^2; % Add estimation error at current frame, fold and lambda to the estimation error for this fold and lambda, summing tthe error over the frames
            
            w_old = w_hat; % Set current LASSO estimate as estimate for warm-starting.
            %disp(['Frame: ' num2str(k_frame) ', Fold: ' num2str(k_fold) ', Hyperparam: ' num2str(k_lam)]) % Display progress through frames, folds and lambda-indices.
        end
        
        cv_location = cv_location+cvhop; % Hop to location for next fold.
        %disp(['Frame: ' num2str(k_frame) ', Fold: ' num2str(k_fold)]);
    end
    
    frame_location = frame_location + frame_hop; % Hop to location for next frame.
    disp(['Frame: ' num2str(k_frame)]);
end



MSE_val = mean(SE_val,1); % Average validation error across folds
MSE_est = mean(SE_est,1); % Average estimation error across folds

lambda_opt = lambda_vec(MSE_val == min(MSE_val)); % Assign optimal lambda 

% Move through frames and calculate LASSO estimates using both estimation
% and validation data, store in Wopt.
frame_location = 0;
for k_frame = 1:N_frames
    t = T(frame_location + idx);
    W_opt(:,k_frame) = lasso_ccd(t, X, lambda_opt);
    frame_location = frame_location + frame_hop;
end

RMSE_val = sqrt(MSE_val);
RMSE_est = sqrt(MSE_est);

end

