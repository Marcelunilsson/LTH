% CE1

A = imread("assignment4data\a.jpg");
B = imread("assignment4data\b.jpg");

[f1 d1] = vl_sift(single(rgb2gray(A)), 'PeakThresh', 1);
[f2 d2] = vl_sift(single(rgb2gray(B)), 'PeakThresh', 1);

figure
imagesc(A);
hold on
axis equal
vl_plotframe(f1);


figure
imagesc(B);
hold on
axis equal
vl_plotframe(f2);

matches = vl_ubcmatch(d1, d2);

x1 = [f1(1, matches (1 ,:)); f1(2, matches (1 ,:))];
x2 = [f2(1, matches (2 ,:)); f2(2, matches (2 ,:))];

perm = randperm( size ( matches ,2));
figure ;
imagesc([A B]);
hold on;
plot([x1(1, perm (1:10)); x2(1, perm (1:10))+ size(A ,2)] , [x1(2, perm(1:10)); x2(2, perm(1:10))], '-');
hold off;
%% Print outs

% How many sift features
disp('number of sift features')
[length(f1) length(f2)]
% How many matches
disp('number of matches')
length(matches)



%%
x1h = [x1;
    ones(1, length(x1))];

x2h = [x2;
    ones(1, length(x2))];
 cp = [];
iter = 5000;
for i=1:iter
    % get four random points
    randsel = randperm(length(x1), 4);
    xe1 = [x1(:, randsel); ones(1,4)];
    xe2 = [x2(:, randsel); ones(1,4)];

    % Calculate an estimated H
    Me = zeros(12, 13);
    for j = 1:length(xe1)
        Me(3*j-2:3*j,:) = [xe1(:, j)' zeros(1, 6) zeros(1, j-1) xe2(1, j) zeros(1, 4-j);
            zeros(1, 3) xe1(:, j)' zeros(1, 3) zeros(1, j-1) xe2(2, j) zeros(1, 4-j);
            zeros(1, 6) xe1(:, j)' zeros(1, j-1) xe2(3, j) zeros(1, 4-j)];
    end
    
    [Ue,Se,Ve] = svd(Me);
    ve = Ve(1:9, end);
    He = [ve(1:3)';
        ve(4:6)';
        ve(7:9)'];
    
    % Apply estimated H
    x1est = pflat(He * x1h);
    
    
    
    
    % Se how many corresponding points are less then 5 pixels of (concensus
    % points)
    cps = [];
    for cpi = 1:length(x1h)
        xerr = x2h(1, cpi) - x1est(1, cpi);
        yerr = x2h(2, cpi) - x1est(2, cpi);
        if (sqrt(xerr^2 + yerr^2) <= 5)
            cps(end+1) = cpi;
        end
    end
  
    % Save list of corresponding points if lengt longer then the current
    if (length(cps) >= length(cp))
        cp = cps;
        Hest = He;
    end
end

Hest = Hest ./ Hest(end, end);

% print number of inliers
disp('number of inliers')
length(cp)


% Transform image to comon coordinate system
Htform = projective2d(Hest');
Rout = imref2d ( size(A) ,[ -200 800] ,[ -400 600]);
[Atransf] = imwarp(A,Htform ,'OutputView',Rout );
Idtform = projective2d(eye(3));
[Btransf] = imwarp(B, Idtform ,'OutputView',Rout );
AB = Btransf;
AB( Btransf < Atransf ) = Atransf( Btransf < Atransf );
imagesc( Rout . XWorldLimits , Rout . YWorldLimits ,AB );


%% CE2

load("assignment4data\compEx2data.mat");
im1 =  imread("assignment4data\im1.jpg");
im2 =  imread("assignment4data\im2.jpg");
x1 = [x{1}; ones(1, length(x{1}))];
x2 = [x{2}; ones(1, length(x{1}))];

cp = [];
l1 = [];
l2 = [];
E = [];
F = [];
iter = 500;
for i = 1:iter
    % get five random points
    randsel = randperm(length(x1), 5);
    x1r = x1(:, randsel);
    x2r = x2(:, randsel);
    
    x1rn = K\x1r;
    x2rn = K\x2r;
    % Calculate essential matrix estimation
    Ei = fivepoint_solver(x1rn, x2rn);
    
    for j = 1:length(Ei)
            
        %compute F
        Fe = K'\Ei{j}/K; 
        Fj = Fe./Fe(3,3);
        
        % compute lines
        l1j = Fj'*x2;
        l1j = l1j./sqrt(repmat(l1j(1,:).^2 + l1j(2,:).^2, [3 1])); %normalize
        
        l2j = Fj*x1;
        l2j = l2j./sqrt(repmat(l2j(1,:).^2 + l2j(2,:).^2, [3 1])); %normalize
        
        % compute distances to lines 
        dist1 = abs(sum(l1j.*x1));
        dist2 = abs(sum(l2j.*x2));
        
        % compute inlier for both images
        cp1 = find(dist1 < 5);
        cp2 = find(dist2 < 5);
        
        % compute matching inliers for both images
        [cpj usch] = intersect(cp1, cp2);
        
        % save the best result
        if (length(cp) < length(cpj)) 
            cp = cpj;
            l1 = l1j;
            l2 = l2j;
            F = Fj;
            E = Ei{j};
        end
    end    
end
% Print number of inliers
disp('Nbr of Inliers');
length(cp)

%%
%Plot that shit

figure(1)
imagesc(im2)
hold on
plot(x2(1,cp), x2(2,cp), 'y*', 'Markersize', 10) 
rital(l2(:,cp))
hold off
axis equal

figure(2)
imagesc(im1)
hold on
plot(x1(1,cp), x1(2,cp), 'y*', 'Markersize', 10) 
rital(l1(:,cp))
hold off
axis equal

figure
hist(abs(sum(l2.*x2)) ,100);

%% Triangulate

[UE,SE,VE] = svd(E);

if det(UE*VE') > 0
    Ef = UE*diag([1 1 0])*VE';
else
    VE = -VE;
    Ef = UE*diag([1 1 0])*VE';
end

Ef = Ef ./ Ef(end, end);

W = [0 -1 0; 1 0 0; 0 0 1];
P1 = [eye(3, 3) zeros(3, 1)];
P2 = {[UE*W*VE' UE(:, end)], [UE*W*VE' -UE(:, end)], [UE*W'*VE' UE(:, end)], [UE*W'*VE' -UE(:, end)]};

in_front = 0;
bestP2 = 0;
bestX = 0;

x1n = K\x1(:, cp);
x2n = K\x2(:, cp);

for i=1:4
    
    % Triangulate
    X = [];
    for j = 1:length(cp)
        Me4 = [P1 x1n(:,j) zeros(3,1) ; P2{i} zeros(3,1) x2n(:,j)];
        [Ut, St, Vt] = svd(Me4);
        X(:,j) = pflat(Vt(1:4,end));
    end
    
    % Check number of points in front of camera
    temp = sum(P1(3,:)*X > 0 & P2{i}(3,:)*X > 0);
    if  temp >= in_front
        bestP2 = P2{i};
        bestX = X;
        in_front = temp;
    end
end


P2f = K*bestP2;
X = bestX;
xe = pflat(P2f*X);



figure
plot3(X(1, :), X(2, :), X(3, :), '.');
hold on;
axis equal;
plotcams({P1, P2f})


%% Reproject into cameras and plot error

x1e = pflat(K*P1*X);
x2e = pflat(K*bestP2*X);


figure(1)
imagesc(im2)
hold on
plot(x2e(1,:), x2e(2,:), 'b*', 'Markersize', 10) 
plot(x2(1,:), x2(2,:), 'y.', 'Markersize', 10) 
hold off
axis equal

figure(2)
imagesc(im1)
hold on
plot(x1e(1,:), x1e(2,:), 'b*', 'Markersize', 10) 
plot(x1(1,:), x1(2,:), 'y.', 'Markersize', 10) 
hold off
axis equal

figure
hist(sum(abs(x2(:, cp)-x2e)) ,100);

figure
hist(sum(abs(x1(:, cp)-x1e)) ,100);

% RMS error
disp('RMS x1')
mean(sqrt(sum((x1(:, cp)-x1e).^2)))
disp('RMS x2')
mean(sqrt(sum((x2(:, cp)-x2e).^2)))

%% CE3
P = {K*P1 P2f};
U = X;
u = {x1(:, cp) x2(:, cp)};

iter = 2000;
gammak = 1;
rnorms = zeros(1, iter);
[r,J] = LinearizeReprojErr(P,U,u);
for i = 1:iter
    lastr = r;
    while 1
        deltav = -gammak*J'*r;
        [Pnew , Unew ] = update_solution(deltav ,P,U);
        [r,J] = LinearizeReprojErr(Pnew,Unew,u); 
        if norm(r) >= norm(lastr)
            gammak = .5* gammak;
        else
            P = Pnew;
            U = Unew;
            break;
        end
    end
    rnorms(i) = norm(r);
end
figure
plot(linspace(1, iter, iter), rnorms,  'b')

Pnew{2} = Pnew{2}./Pnew{2}(end, end);
x1e = pflat(Pnew{1}*Unew);
x2e = pflat(Pnew{2}*Unew);



figure
imagesc(im1)
hold on
plot(x1e(1,:), x1e(2,:), 'b*', 'Markersize', 10) 
plot(x1(1,:), x1(2,:), 'y.', 'Markersize', 10) 
hold off
axis equal
figure
imagesc(im2)
hold on
plot(x2e(1,:), x2e(2,:), 'b*', 'Markersize', 10) 
plot(x2(1,:), x2(2,:), 'y.', 'Markersize', 10) 
hold off
axis equal

% RMS error
disp('RMS x1')
mean(sqrt(sum((x1(:, cp)-x1e).^2)))
disp('RMS x2')
mean(sqrt(sum((x2(:, cp)-x2e).^2)))

%% CE4

P = {K*P1 P2f};
U = X;
u = {x1(:, cp) x2(:, cp)};

iter = 25;
lambda = .1;
rnorms = zeros(1, iter);
[r,J] = LinearizeReprojErr(P,U,u);
C = J'*J+lambda*speye(size(J ,2));
c = J'*r;
deltav = -C\c;
[Pnew , Unew ] = update_solution(deltav ,P,U);
for i = 1:iter
    lastr = r;
    C = J'*J+lambda*speye(size(J ,2));
    c = J'*r;
    deltav = -C\c;
    [Pnew , Unew ] = update_solution(deltav ,Pnew,Unew);
    [r,J] = LinearizeReprojErr(Pnew,Unew,u);
    rnorms(i) = norm(r); 
end

figure(1)
plot(linspace(1, iter, iter), rnorms,  'b')

x1e = pflat(Pnew{1}*Unew);
x2e = pflat(Pnew{2}*Unew);



figure(2)
imagesc(im1)
hold on
plot(x1e(1,:), x1e(2,:), 'b*', 'Markersize', 10) 
plot(x1(1,:), x1(2,:), 'y.', 'Markersize', 10) 
hold off
axis equal

figure(3)
imagesc(im2)
hold on
plot(x2e(1,:), x2e(2,:), 'b*', 'Markersize', 10) 
plot(x2(1,:), x2(2,:), 'y.', 'Markersize', 10) 
hold off
axis equal

% RMS error
disp('RMS x1')
mean(sqrt(sum((x1(:, cp)-x1e).^2)))
disp('RMS x2')
mean(sqrt(sum((x2(:, cp)-x2e).^2)))
