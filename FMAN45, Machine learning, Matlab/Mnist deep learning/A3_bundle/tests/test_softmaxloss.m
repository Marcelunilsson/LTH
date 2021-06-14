function test_softmaxloss()
    addpath(genpath('../'));
    
    x = [1 2 -1;
        2 4 -2];
    labels = [1 2 1];
    res = 1/3*((-1 + log(exp(1)+exp(2))) ...
        + (-4 + log(exp(2) + exp(4))) ...
        + (1 + log(exp(-1) + exp(-2))));
    test_equal(softmaxloss_forward(x, labels), res, ...
        1e-5, 'The forward pass is incorrect.');

    % gradients
    for k=1:5
        x = randn(21,4);
        labels = randi(21,1,4);
        y = softmaxloss_forward(x, labels);
        dldx = softmaxloss_backward(x, labels);
        % no need to square this time since we have scalar output
        test_gradients(@(x) softmaxloss_forward(x, labels), dldx, x, 1e-5, 30);
    end

    fprintf('Everything passed! Your implementation seems correct.\n');
end