function tests()
    addpath(genpath('../'));
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% convolution

    % identity convolution
    x = randn(5,5,3,2);
    w = zeros(1,1,3,3);
    w(1,1,1,1) = 1;
    w(1,1,2,2) = 1;
    w(1,1,3,3) = 1;
    b = zeros(3,1);

    test_equal(convolution_forward(x, w, b), x, 1e-5, 'Identity convolution');

    % impulse
    x = zeros(5,5,1,1);
    x(3,3,1,1) = 1;
    w = ones(5,5,1,1);
    b = zeros(1,1);
    test_equal(convolution_forward(x, w, b), [1], 1e-5, 'impulse');

    x = zeros(3,3,2,2);
    x(:,:,1,1) = [1 2 3; 4 5 6; 7 8 9];
    x(:,:,2,1) = [-1 2 -3; 4 -5 6; -7 8 -9];
    w = zeros(2,2,2,2);
    w(:,:,1,1) = [1 2; 3 4];
    w(:,:,2,1) = [0 1; 0 1];
    w(:,:,1,2) = [0 1; 1 0];
    w(:,:,2,2) = [1 1; 1 1];
    b = zeros(2,1);
    res = zeros(2,2,2,2);
    res(:,:,1,1) = [34 50; 70 74];
    res(:,:,2,1) = [6 8; 12 14];
    test_equal(convolution_forward(x, w, b), res, 1e-5, 'test');

    % bias
    x = zeros(5,5,2,24);
    w = zeros(3,3,2,4);
    b = randn(4,1);
    c = convolution_forward(x, w, b);
    for k = 1:4
        test_equal(c(1,1,k,1), b(k), 1e-5, 'bias incorrect');
    end
    
    fprintf('Check\n');
    for k = 1:5
        x = randn(5,7,4,3);
        w = randn(3,3,4,2);
        b = randn(2,1);
        y = convolution_forward(x, w, b);
        [dldx, dldw, dldb] = convolution_backward(x, y, w, b);
        test_gradients(@(x) 0.5*sum(vec(convolution_forward(x, w, b).^2)), dldx, x, 1e-5, 30);
        test_gradients(@(w) 0.5*sum(vec(convolution_forward(x, w, b).^2)), dldw, w, 1e-5, 30);
        test_gradients(@(b) 0.5*sum(vec(convolution_forward(x, w, b).^2)), dldb, b, 1e-5, 5);
    end

    %%%%% conv with padding
    for k=1:5
        x = randn(5,5,3,2);
        w = randn(3,3,3,6);
        b = randn(6,1);

        test_equal(convolution_forward(x, w, b), conv_with_padding_forward(x, w, b, [0,0]), 1e-5,...
             'Zero padding does not give the same result as ordinary convolution');
    end

    x = zeros(3,3,1,1);
    w = zeros(3,3,1,1);
    w(:,:,1,1) = [1 2 3; 4 5 6; 7 8 9];
    x(:,:,1,1) = [1 0 1; 0 1 0; 1 0 1];
    b = [1];
    res = [14 18 12; 16 25 14; 8 12 6] + 1;
    test_equal(conv_with_padding_forward(x, w, b, [1,1]), res, 1e-5, 'Padding incorrect');

    for k = 1:5
        x = randn(5,7,4,3);
        w = randn(3,3,4,2);
        b = randn(2,1);
        padding = randi(4, 2,1);
        y = conv_with_padding_forward(x, w, b, padding);
        [dldx, dldw, dldb] = conv_with_padding_backward(x, y, w, b, padding);
        test_gradients(@(x) 0.5*sum(vec(conv_with_padding_forward(x, w, b, padding).^2)), dldx, x, 1e-5, 30);
        test_gradients(@(w) 0.5*sum(vec(conv_with_padding_forward(x, w, b, padding).^2)), dldw, w, 1e-5, 30);
        test_gradients(@(b) 0.5*sum(vec(conv_with_padding_forward(x, w, b, padding).^2)), dldb, b, 1e-5, 5);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% maxpooling
    x = zeros(4,4,3,2);
    x(:,:,1,1) = [1 2 3 4;
                  5 6 7 8;
                  -3 -5 6 7;
                  3 4 1 0];

    y = zeros(2,2,3,2);
    y(:,:,1,1) = [6 8; 4 7];
    test_equal(maxpooling_forward(x), y, 1e-5, 'Maxpooling incorrect');

    for k=1:5
        x = randn(8,12,4,3);
        y = maxpooling_forward(x);
        dldx = maxpooling_backward(x, y);
        test_gradients(@(x) 0.5*sum(vec(maxpooling_forward(x).^2)), dldx, x, 1e-5, 30);
    end


    %%%%%%%%%%%%% conv and pooling
    for k=1:5
        x = randn(8,8,3,2);
        w = randn(3,3,3,3);
        b = randn(3,1);
        y_0 = convolution_forward(x,w,b);
        y_1 = maxpooling_forward(y_0);
        [dldx,dldw,dldb] = convolution_backward(x, maxpooling_backward(y_0, y_1), w, b);
        
        test_gradients(@(x) 0.5*sum(vec(maxpooling_forward(convolution_forward(x,w,b)).^2)) ...
            , dldx, x, 1e-5, 30);
        test_gradients(@(w) 0.5*sum(vec(maxpooling_forward(convolution_forward(x,w,b)).^2)) ...
            , dldw, w, 1e-5, 5);
        test_gradients(@(b) 0.5*sum(vec(maxpooling_forward(convolution_forward(x,w,b)).^2)) ...
            , dldb, b, 1e-5, 3);
    end

    fprintf('Everything passed!\n');
end