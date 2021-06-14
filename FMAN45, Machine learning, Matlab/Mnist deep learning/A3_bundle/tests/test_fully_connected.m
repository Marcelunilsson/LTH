function test_fully_connected()
    addpath(genpath('../'));
    % This file contains various tests to verify that your implementation
    % for the fully connected layer is correct. It check a number of
    % forward passes first and compares with the expected results and then
    % it perform exhaustive gradient checking using the methodology
    % described in the assignment.
    
    % one batch
    x = zeros(2,1);
    x(:,1) = [1 2];
    A = [-1 3; 7 -3];
    b = zeros(2,1);
    res = zeros(2,1);
    res(:,1) = [5 1];
    test_equal(fully_connected_forward(x, A, b), res, 1e-5, 'Forward pass with a batch of one is incorrect');

    b(:,1) = [2 3];
    res(:,1) = [7 4];
    test_equal(fully_connected_forward(x, A, b), res, ...
        1e-5, 'Forward pass with a batch of one is incorrect. Check the bias');

    % batch of two
    x = zeros(3,2);
    x = [1 2 3;
        2 1 1;
        3 2 1];
    A = [1 0 1; 0 1 0; -1 1 1];
    b = [-1; 0; 1];
    res = [3 3 3; 2 1 1; 5 2 0];
    test_equal(fully_connected_forward(x, A, b), res, ...
        1e-5, 'Forward pass with a batch of two is incorrect.');
    
    % using vec on the input
    x = reshape(1:8, [2,2,2]);
    A = [1 1 2 2];
    b = 0;
    res = [17 41];
    test_equal(fully_connected_forward(x, A, b), res, ...
        1e-5, 'Forward pass with input that is not vectorized fails. Make sure that you reshape x to size [features, elements in the batch].');

    % gradients
    for k=1:5
        x = randn(21,4);
        A = randn(3, 21);
        b = randn(3,1);
        y = fully_connected_forward(x, A, b);
        [dldx, dldA, dldb] = fully_connected_backward(x, y, A, b);
        test_gradients(@(x) 0.5*sum(vec(fully_connected_forward(x, A, b).^2)), dldx, x, 1e-5, 30);
        test_gradients(@(A) 0.5*sum(vec(fully_connected_forward(x, A, b).^2)), dldA, A, 1e-5, 30);
        test_gradients(@(b) 0.5*sum(vec(fully_connected_forward(x, A, b).^2)), dldb, b, 1e-5, 5);
    end
    
    for k=1:5
        x = randn(5,3,4);
        A = randn(3, 15);
        b = randn(3,1);
        y = fully_connected_forward(x, A, b);
        [dldx, dldA, dldb] = fully_connected_backward(x, y, A, b);
        test_gradients(@(x) 0.5*sum(vec(fully_connected_forward(x, A, b).^2)), dldx, x, 1e-5, 30);
        test_gradients(@(A) 0.5*sum(vec(fully_connected_forward(x, A, b).^2)), dldA, A, 1e-5, 30);
        test_gradients(@(b) 0.5*sum(vec(fully_connected_forward(x, A, b).^2)), dldb, b, 1e-5, 5);
    end

    fprintf('Everything passed! Your implementation seems correct.\n');
end