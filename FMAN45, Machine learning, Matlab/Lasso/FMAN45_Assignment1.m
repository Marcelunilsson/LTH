load("A1_data.mat")
%%
% Task 4
ll = [0.1 10];
w_hat = [];
f = real(5*exp(i * 2 * pi*(n/20+1/3)) + 2 * exp(i * 2 * pi * (n/5 - 1/4)));
finterp = real(5*exp(i * 2 * pi*(ninterp/20+1/3)) + 2 * exp(i * 2 * pi * (ninterp/5 - 1/4)));
diff = inf;
my_lambda = 0;
min_points = inf;

for lambda = 0:.01:10
    w_hat_i = lasso_ccd(t, X, lambda);
    if (sum(lambda == ll) ~=0)
        w_hat = [w_hat w_hat_i];
        figure()
        plot(ninterp, Xinterp*w_hat_i, "g", "linewidth", .01)
        title(["Lambda = " num2str(lambda) "Non zero points = " sum(w_hat_i ~= 0)])
        xlabel("n")
        ylabel("t-estimate")
        hold on
        plot(ninterp, finterp, "black--")
        plot(n, t, "ro")
        plot(n, X*w_hat_i, "b*")
        legend('Interpolated line', 'True function','True values', 'Predicted values')
        hold off
    end

    if sum(abs(sqrt((X*w_hat_i - f).^2))) < diff
        my_lambda = lambda;
        diff = sum(abs(X*w_hat_i - f));
    end
    
    figure(1)
    plot(n, X*w_hat_i, "g", "linewidth", .01)
    title(["Lambda = " num2str(lambda)])
    xlabel("n")
    ylabel("t-estimate")
    hold on
    plot(ninterp, finterp, "black--")
    plot(n, t, "ro")
    plot(n, X*w_hat_i, "b*")
    legend('Interpolated line', 'True function','True values', 'Predicted values')
    hold off
    
    
    if (sum(w_hat_i ~= 0) < min_points )
        min_points = [sum(w_hat_i ~= 0) lambda];
    end
end

%%
w_hat = [w_hat lasso_ccd(t, X, my_lambda)]
figure()
plot(ninterp, Xinterp*w_hat(:, 3), "g", "linewidth", .01)
title(["Lambda = " num2str(my_lambda) "Non zero points = " sum(w_hat(:, 3) ~= 0)])
xlabel("n")
ylabel("t-estimate")
hold on
plot(ninterp, finterp, "black--")
plot(n, t, "ro")
plot(n, X*w_hat(:, 3), "b*")
legend('Interpolated line', 'True function','True values', 'Predicted values')
hold off
%%
figure()
plot(ninterp, Xinterp*w_hat(:, 1), "r", "linewidth", .01)
hold on
xlabel("n")
ylabel("t-estimate")
plot(ninterp, Xinterp*w_hat(:, 2), "b", "linewidth", .01)
plot(ninterp, Xinterp*w_hat(:, 3), "g", "linewidth", .01)
plot(ninterp, finterp, "black--")
legend('Lambda = 0.1','Lambda 10', ['Lambda = ' num2str(my_lambda)], 'True function')
    
    
%%
% Task 5
lambda_vec = exp(linspace(log(0.001), log(max(abs(X'*t))), 100));
k = 50;
[w_opt,lambda_opt,RMSE_val,RMSE_est] = lasso_cv(t,X,lambda_vec,k);
%%
figure()
loglog(lambda_vec, RMSE_val)
hold on
grid on
title("RMSE vs \lambda plot")
xlabel("\lambda")
ylabel("RMSE")
loglog(lambda_vec, RMSE_val, "r*")
loglog(lambda_vec, RMSE_est, "g")
loglog(lambda_vec, RMSE_est, "b*")
xline(lambda_opt, "k--")
legend("RMSE_{val}","" , "RMSE_{est}","", "\lambda_{opt} = " + lambda_opt)


figure()
plot(n, X*w_opt, "g", "linewidth", 0.1)
title(["Lambda = " num2str(lambda_opt) "Non zero points = " sum(w_opt ~= 0)])
xlabel("n")
ylabel("t-estimate")
hold on
plot(ninterp, finterp, "black--")
plot(n, X*w_opt, "b*")
hold off
legend("Interpolated line","True Function")

%%
% Task 6
lambda_vec = exp(linspace(log(0.001), log(10) , 20));
%lambda_vec = logspace(0.0001, 20 , 10);
K = 6;
[W_opt,lambda_opt,RMSE_val,RMSE_est] = multiframe_lasso_cv(Ttrain,Xaudio,lambda_vec,K);
%%

figure()
loglog(lambda_vec, RMSE_val)
hold on
grid on
title("RMSE vs \lambda plot")
xlabel("\lambda")
ylabel("RMSE")
loglog(lambda_vec, RMSE_val, "r*")
loglog(lambda_vec, RMSE_est, "g")
loglog(lambda_vec, RMSE_est, "b*")
xline(lambda_opt, "k--")
legend("Validation data error","" , "Estimation data error","", "Optimal lambda =" + lambda_opt)

%%
% Task 7
%0.012
%0.0077
lambda_7 = 0.004;
[Tcleaned] = lasso_denoise(Ttest,Xaudio,lambda_7);
soundsc(Tcleaned, fs)
save('denoised_audio_lambda_0_012','Tcleaned','fs')

%%
soundsc(Ttest, fs)

