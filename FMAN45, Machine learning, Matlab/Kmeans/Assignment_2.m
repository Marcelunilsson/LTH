%% A2:E1
clear all
load("A2_data.mat");
X = train_data_01;
% Normalize data
X_proj = proj_2d(X);
index1 = find(train_labels_01 == 1);
index0 = find(train_labels_01 == 0);
figure()
plot(X_proj(index1,1), X_proj(index1,2), 'r*', X_proj(index0,1), X_proj(index0,2),'bo')
title('2 dimensional representation of X')
legend('Class 1', 'Class 0')
xlabel("PCA dim 1")
ylabel("PCA dim 2")
%% A2:E2
clear all
load("A2_data.mat");
X = train_data_01;
X_proj = proj_2d(X);

K=5;
[y, C] = K_means_clustering(train_data_01, K);
cl = ['r' 'g' 'b' 'y' 'c' 'k' 'm' 'w'];

figure()
for i = 1:K
plot(X_proj(y == i ,1), X_proj(y == i,2), [cl(i) '*'])
hold on    
end
title(['2 dimensional representation of X, K = ' num2str(K)])
xlabel("PCA dim 1")
ylabel("PCA dim 2")
%% A2:E3
figure()
for i = 1:K
    im = reshape(C(:,i), 28, 28);
    imbig = imresize(im, 10);
    ax = subplot(2, 3, i);
    imshow(imbig)
    title(['Cluster number' num2str(i)])
end


%% A2:E4
clear all
load("A2_data.mat");
X = train_data_01;
X_proj = proj_2d(X);

K=2;
[y, C] = K_means_clustering(X, K);

figure()
for i = 1:K
    im = reshape(C(:,i), 28, 28);
    imbig = imresize(im, 10);
    ax = subplot(2, 5, i);
    imshow(imbig)
    title(['Cluster number' num2str(i)])
end
cl = ['r' 'g' 'b' 'y' 'c' 'k' 'm' 'w'];
figure()
for i = 1:K
plot(X_proj(y == i ,1), X_proj(y == i,2), [cl(i) '*'])
hold on    
end


%%
labels = [0 1];
[y_pred_train, Cx] = K_means_classifier(train_data_01, C, labels);

correct_train = sum(y_pred_train' == train_labels_01);
for i = 1:K
    C_corr_train(i) = sum(train_labels_01(Cx == i) == labels(i));
    C_miss_train(i) = sum(train_labels_01(Cx == i) == (1 - labels(i)));
    C_class_train(i) = labels(i);
end
miss_class_rate_train = 100 * sum(C_miss_train) / length(y_pred_train)

%%
[y_pred_test, Cx] = K_means_classifier(test_data_01, C, labels);

correct_test = sum(y_pred_test' == test_labels_01);
for i = 1:K
    C_corr_test(i) = sum(test_labels_01(Cx == i) == labels(i));
    C_miss_test(i) = sum(test_labels_01(Cx == i) == (1 - labels(i)));
    C_class_test(i) = labels(i);
end

miss_class_rate_test = 100 * sum(C_miss_test) / length(y_pred_test)


%% A2:E5

% Yes


%% A2:E6
clear all
load("A2_data.mat");

svm = fitcsvm(train_data_01', train_labels_01);
y_pred_test = predict(svm, test_data_01');

pred_zero_true_zero_test = sum(test_labels_01(y_pred_test == 0) == 0);
pred_zero_true_one_test = sum(test_labels_01(y_pred_test == 0) == 1);

pred_one_true_one_test = sum(test_labels_01(y_pred_test == 1) == 1);
pred_one_true_zero_test = sum(test_labels_01(y_pred_test == 1) == 0);

miss_class_test = pred_one_true_zero_test + pred_zero_true_one_test;
miss_class_rate_test = 100 * miss_class_test / length(y_pred_test);

y_pred_train = predict(svm, train_data_01');

pred_zero_true_zero_train = sum(train_labels_01(y_pred_train == 0) == 0);
pred_zero_true_one_train = sum(train_labels_01(y_pred_train == 0) == 1);

pred_one_true_one_train = sum(train_labels_01(y_pred_train == 1) == 1);
pred_one_true_zero_train = sum(train_labels_01(y_pred_train == 1) == 0);

miss_class_train = pred_zero_true_one_train + pred_one_true_zero_train;
miss_class_rate_train = 100 * miss_class_train / length(y_pred_train);

%% A2:E7
clear all
load("A2_data.mat");
beta = 5;
svm_gauss = fitcsvm(train_data_01', train_labels_01, 'KernelFunction', 'gaussian', 'KernelScale', beta);

y_pred_test = predict(svm_gauss, test_data_01');

pred_zero_true_zero_test = sum(test_labels_01(y_pred_test == 0) == 0);
pred_zero_true_one_test = sum(test_labels_01(y_pred_test == 0) == 1);

pred_one_true_one_test = sum(test_labels_01(y_pred_test == 1) == 1);
pred_one_true_zero_test = sum(test_labels_01(y_pred_test == 1) == 0);

miss_class_test = pred_one_true_zero_test + pred_zero_true_one_test;z
miss_class_rate_test = 100 * miss_class_test / length(y_pred_test);

y_pred_train = predict(svm_gauss, train_data_01');

pred_zero_true_zero_train = sum(train_labels_01(y_pred_train == 0) == 0);
pred_zero_true_one_train = sum(train_labels_01(y_pred_train == 0) == 1);

pred_one_true_one_train = sum(train_labels_01(y_pred_train == 1) == 1);
pred_one_true_zero_train = sum(train_labels_01(y_pred_train == 1) == 0);

miss_class_train = pred_zero_true_one_train + pred_one_true_zero_train;
miss_class_rate_train = 100 * miss_class_train / length(y_pred_train);


%% A2:E8

