function test_equal(a, b, epsilon, msg)
    if size(a) ~= size(b)
        error('Sizes do not match');
    end
    a_ = a;
    b_ = b;
    a = a(:);
    b = b(:);
    if(max(abs(a - b) ./ (abs(a) + abs(b) + 1e-7)) > epsilon)
        expected = b_
        got = a_
        fprintf('######### FAILED TEST ##################');
        error(msg);
    end
end