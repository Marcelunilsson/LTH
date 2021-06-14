
load("models\network_trained_with_momentum.mat")
%%
figure()
for i = 1:16
    ax = subplot(4, 4, i);
    imagesc(net.layers{1, 2}.params.weights(:, :, 1, i))
    title(['Kernel number ' num2str(i)])
    colormap(gray)
end
%%
training_opts = struct('learning_rate', 1e-1, ...
        'iterations', 3000,...
        'batch_size', 1,...
        'momentum', 0.9,...
        'weight_decay', 0.005);
x_test = loadMNISTImages('data/mnist/t10k-images.idx3-ubyte');
y_test = loadMNISTLabels('data/mnist/t10k-labels.idx1-ubyte');
y_test(y_test==0) = 10;
x_test = reshape(x_test, [28, 28, 1, 10000]);
pred = zeros(numel(y_test),1);
batch = training_opts.batch_size;
for i=1:batch:size(y_test)
    idx = i:min(i+batch-1, numel(y_test));
    % note that y_test is only used for the loss and not the prediction
    y = evaluate(net, x_test(:,:,:,idx), y_test(idx));
    [~, p] = max(y{end-1}, [], 1);
    pred(idx) = p;
end

fprintf('Accuracy on the test set: %f\n', mean(vec(pred) == vec(y_test)));
%%
y_test(y_test==10) = 0;
pred(pred==10)=0;
error_index = find(pred ~= y_test);
error_index = error_index(randperm(length(error_index)));
figure()
for i = 1:16
    ax = subplot(4, 4, i);
    imagesc(x_test(:, :, 1, error_index(i)));
    title(['True digit ' num2str(y_test(error_index(i))) ', Predicted digit ' num2str(pred(error_index(i)))]);
    colormap(gray)
end

%%

confusionchart(y_test, pred)
conf = confusionmat(y_test, pred);

precision = @(conf) diag(conf)./sum(conf,2);

recall = @(conf) diag(conf)./sum(conf,1)';

layerparams = @(i) numel(net.layers{1,i}.params.weights) + numel(net.layers{1, i}.params.biases);
%plotconfusion(y_test,pred)
%%
load("models\cifar10_baseline_128.mat");
[x_train, y_train, x_test, y_test, classes] = load_cifar10(2);
data_mean = mean(mean(mean(x_train, 1), 2), 4);
x_test = bsxfun(@minus, x_test, data_mean);

pred = zeros(numel(y_test),1);
batch = 32;
for i=1:batch:size(y_test)
    idx = i:min(i+batch-1, numel(y_test));
    % note that y_test is only used for the loss and not the prediction
    y = evaluate(net, x_test(:,:,:,idx), y_test(idx));
    [~, p] = max(y{end-1}, [], 1);
    pred(idx) = p;
end

fprintf('Accuracy on the test set: %f\n', mean(vec(pred) == vec(y_test)));
%%











%%
[x_train, y_train, x_test, y_test, classes] = load_cifar10(4);
realx_test = x_test;
data_mean = mean(mean(mean(x_train, 1), 2), 4); % mean RGB triplet
x_test = bsxfun(@minus, x_test, data_mean);

training_opts = struct('learning_rate', 1e-3,...
    'iterations', 5000,...
    'batch_size', 128,...
    'momentum', 0.95,...
    'weight_decay', 0.001);
    % evaluate on the test set
pred = zeros(numel(y_test),1);
batch = training_opts.batch_size;
for i=1:batch:size(y_test)
    idx = i:min(i+batch-1, numel(y_test));
    % note that y_test is only used for the loss and not the prediction
    y = evaluate(net, x_test(:,:,:,idx), y_test(idx));
    [~, p] = max(y{end-1}, [], 1);
    pred(idx) = p;
end

fprintf('Accuracy on the test set: %f\n', mean(vec(pred) == vec(y_test)));
%%
% Print kernels
figure()
for i = 1:16
    ax = subplot(4, 4, i);
    imagesc(net.layers{1, 2}.params.weights(:, :, 1, i))
    title(['Kernel number ' num2str(i)])
end

%%
%Print missclass
error_index = find(pred ~= y_test);
error_index = error_index(randperm(length(error_index)));
figure()
for i = 1:4
    ax = subplot(2, 2, i);
    imagesc(realx_test(:, :, :, error_index(i))/255);
    title(['True Class ' classes{y_test(error_index(i))} ', Predicted Class ' classes{pred(error_index(i))}]);
end
%%
% Conf recall etc

confusionchart(double(y_test), pred)
conf = confusionmat(double(y_test), pred);

precision = @(conf) diag(conf)./sum(conf,2);

recall = @(conf) diag(conf)./sum(conf,1)';

precrec7 = ["class", "Precision", "Recall";
    [1:10]' precision(conf) recall(conf)]

layerparams = @(i) numel(net.layers{1,i}.params.weights) + numel(net.layers{1, i}.params.biases);
