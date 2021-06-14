function test_gradients(f, g, x0, epsilon, n)
    reference = g; %g(x0);

    assert(isequal(size(x0), size(g)), 'The gradient has a different dimensionality than expected. Make sure that e.g. x and dLdx has the exact same shape.')
    
    fprintf('Gradient testing\n');
    fprintf('       idx  %13s%13s%13s\n', 'Fin diff', 'Backprop', 'Rel. diff');
    for k = 1:n
        idx = randi(numel(x0), 1);
        pos = x0;
        pos(idx) = pos(idx) + epsilon;
        neg = x0;
        neg(idx) = neg(idx) - epsilon;
        d = (f(pos) - f(neg)) / (2*epsilon);
        r = reference(idx);
        rel = abs(d-r) / (abs(d) + abs(r) + 1e-8);
        fprintf('It %2d %3d: %13.5e %13.5e %13.4e\n', k, idx, d, r, rel);

        if(rel > 1e-5)
            error('Unacceptably large gradient error.');
        end
    end
end