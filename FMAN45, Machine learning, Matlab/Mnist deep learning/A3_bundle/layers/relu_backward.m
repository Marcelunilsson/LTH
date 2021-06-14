function dldX = relu_backward(X, dldZ)
    dldX = dldZ .* (X >= 0);
    %dldX = dldZ .* heaviside(X);
end
