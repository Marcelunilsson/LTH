% Computer exercise 1
load("assignment3data\compEx1data.mat");

% Normalize the x vectors

% Calc mean values
meanx1 = mean(x{1}(1, :));
meany1 = mean(x{1}(2, :));
meanx2 = mean(x{2}(1, :));
meany2 = mean(x{2}(2, :));
% Calc standard devs
stdx1 = std(x{1}(1, :));
stdy1 = std(x{1}(2, :));
stdx2 = std(x{2}(1, :));
stdy2 = std(x{2}(2, :));
%Construct normalization matrices
N1 = [1/stdx1 0 -meanx1/stdx1; 
    0 1/stdy1 -meany1/stdy1;
    0 0 1];
N2 = [1/stdx2 0 -meanx2/stdx2;
    0 1/stdy2 -meany2/stdy2;
    0 0 1];
% Normalized x-vectors
xn1 = N1 * x{1}; 
xn2 = N2 * x{2}; 

% Set up the M matrix
M = zeros(length(xn1), 9);
for i = 1:length(xn1)
    xx = xn2 (:,i)* xn1 (:,i)';
    M(i ,:) = xx (:)';
end
%%
% Solve with svd
[U,S,V] = svd(M);

% Construct normalized F
v = V(:, end);
Fn = reshape(v, [3 3]);

% det(Fn) != 0 --
det(Fn);   % 4.1357e-12
% Epipolar constraint !=0
xn2(:, 1)' * Fn * xn1(:, 1); % -1.0028

% Creating closest matrix, Fnc with det(Fnc) = 0  <----- FUCK THIS SHIT 
[Uc, Sc, Vc] = svd(Fn);
Sc(3, 3) = 0;
Fnc = Uc*Sc*Vc;
det(Fnc); % -2.5416e-24
xn2(:, 1)' * Fnc * xn1(:, 1); % 1.1148

% Compute F
F = N2' * Fn * N1;
F = F ./F(end, end);
F
% Compute epipolar lines
l = F*x{1};
l = l./ sqrt ( repmat (l (1 ,:).^2 + l (2 ,:).^2 ,[3 1]));
%l = l(1:end, :)./l(end, :)
% Pick out 20 random points
r = randi([1 2008], 20, 1);

% plot picture, 20 points and epipolar lines
kronan1 = imread("assignment3data\kronan1.JPG");
kronan2 = imread("assignment3data\kronan2.JPG");
figure
imagesc(kronan2);
hold on;
axis equal;
randx = x{2}(:,r');
randl = l(:, r');
plot(randx(1, :), randx(2, :), '*');
rital(randl);


figure
hist(abs(sum(l.*x {2})) ,100);

m = mean(abs(sum(l.*x {2})));


%% Computer exercise 2

% Calculate P2 from F
[U2, S2, V2] = svd(F');
e2 = V2(:, end);
e2x = [0 -e2(3) e2(2); e2(3) 0 -e2(1); -e2(2) e2(1) 0];
P1 = [eye(3, 3) zeros(3, 1)];
P2 = -[e2x*F e2];

P1N1 = N1*P1;
P2N2 = N2*P2;

% Triangulation with DLT
Xa = ones(4, length(xn1));
for i = 1:length(xn1)
    M2 = [P1N1 -xn1(1:3,i) zeros(3,1);
        P2N2 zeros(3, 1) -xn2(1:3,i)];
    [U2, S2, V2] = svd(M2);
    v2 = V2(:, end);
    Xa(1:4, i) = v2(1:4);
end
Xa2 = [Xa(1:2, :);Xa(4, :);Xa(3, :)];
Xa2 = pflat(Xa2);
Xa = pflat(Xa);
x1p = pflat(N1\P1N1*Xa);
x2p = pflat(N2\P2N2*Xa);

figure(1)
imagesc(kronan2);
hold on;
axis equal;
randx = x{2}(:,r');
randl = l(:, r');
plot(x{2}(1,:), x{2}(2, :), 'r*');
plot(x2p(1, :), x2p(2, :), 'b+');


figure(2)
plot3(Xa(1, :), Xa(2, :), Xa(3, :), '.');

P1N12 = [P1N1(:, 1:2) P1N1(:, 4) P1N1(:, 3)];
P2N22 = [P2N2(:, 1:2) P2N2(:, 4) P1N1(:, 3)];

x1p2 = pflat(P1N12*Xa2);
x2p2 = pflat(P2N22*Xa2);

figure(3)
imagesc(kronan2);
hold on;
axis equal;
randx = x{2}(:,r');
randl = l(:, r');
plot(x{2}(1,:), x{2}(2, :), 'r*');
plot(x2p2(1, :), x2p2(2, :), 'b+');


figure(4)
plot3(Xa2(1, :), Xa2(2, :), Xa2(3, :), '.');

%% Computer exercise 3
load("assignment3data\compEx3data.mat");

% Normalise image points with K inverse
x1kn =  K \ x{1};
x2kn =  K \ x{2};

% Set up M- matrix
M3 = zeros(length(x1kn), 9);
for i = 1:length(x1kn)
    xx = x2kn (:,i)* x1kn (:,i)';
    M3(i ,:) = xx (:)';
end

% solve svd
[U3,S3,V3] = svd(M3);
v3 = V3(:, end);
min(diag(S3)); % 0.0066
norm(M3*v3); % 0.0066

Ea = reshape(v3, [3 3]);
[UE,SE,VE] = svd(Ea);

if det(UE*VE') > 0
    E = UE*diag([1 1 0])*VE';
else
    VE = -VE;
    E = UE*diag([1 1 0])*VE';
end

for i = 1:100
    x2kn(:, i)'*E*x1kn(:, i);
end

E = E./E(3, 3);
F = K'\E/K;

le3 = F*x{1}
% Pick out 20 random points
r = randi([1 2008], 20, 1);
figure
imagesc(kronan2);
hold on;
axis equal;
randx = x{2}(:,r');
randl = le3(:, r');
plot(randx(1, :), randx(2, :), 'r*');
rital(randl);


figure
hist(abs(sum(le3.*x {2})) ,100);


%% Computer Exercise 4

W = [0 -1 0; 1 0 0; 0 0 1];
P2e4 = {[UE*W*VE' UE(:, end)], [UE*W*VE' -UE(:, end)], [UE*W'*VE' UE(:, end)], [UE*W'*VE' -UE(:, end)]};

in_front = 0;
bestP2 = 0;
bestX = 0;

for i=1:4
    
    % Triangulate
    X = [];
    for j = 1:length(x2kn)
        Me4 = [P1 x1kn(:,j) zeros(3,1) ; P2e4{i} zeros(3,1) x2kn(:,j)];
        [Ut, St, Vt] = svd(Me4);
        X(:,j) = pflat(Vt(1:4,end));
    end
    
    % Check number of points in front of camera
    temp = sum(P1(3,:)*X > 0 & P2e4{i}(3,:)*X > 0);
    if  temp >= in_front
        bestP2 = P2e4{i};
        bestX = X;
        in_front = temp;
    end
end


P2f = K*bestP2;
X = bestX;
xe = pflat(P2f*X);

figure
imagesc(kronan2);
hold on;
axis equal;
randx = x{2}(:,r');
randl = l(:, r');
plot(x{2}(1,:), x{2}(2, :), 'r*');
plot(xe(1, :), xe(2, :), 'b+');


figure
plot3(X(1, :), X(2, :), X(3, :), '.');
hold on;
axis equal;
plotcams({P1, P2f})
