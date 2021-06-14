function test_gradient_whole_net()
    addpath(genpath('../'));
    % Test the gradient using the evaluate funtion

    net.layers = {};
    net.layers{end+1} = struct('type', 'input',...
        'params', struct('size', [3, 2]));
    
    net.layers{end+1} = struct('type', 'fully_connected',...
        'params', struct('weights', randn(3,6), 'biases', randn(3,1)));
    
    net.layers{end+1} = struct('type', 'relu');
    
    net.layers{end+1} = struct('type', 'softmaxloss');

    for k=1:3
        x = randn(3, 2, 2);
        labels = randi(3,2,1);
        [y, grads] = evaluate(net, x, labels);

        test_gradients(@(y) change_one_param(y, net, x, labels, 2, 'biases'), grads{2}.biases, net.layers{2}.params.biases, 1e-5, 5);
        test_gradients(@(y) change_one_param(y, net, x, labels, 2, 'weights'), grads{2}.weights, net.layers{2}.params.weights, 1e-5, 30);
        %fprintf('Loss %f\n', y{end});
    end
    fprintf('Everything passed!\n');
end

function y = change_one_param(param, net, x, labels, id, name)
    x0 = net.layers{id}.params.(name);
    net.layers{id}.params.(name) = param;
    res = evaluate(net, x, labels);
    y = res{end};
    net.layers{id}.params.(name) = x0;
end