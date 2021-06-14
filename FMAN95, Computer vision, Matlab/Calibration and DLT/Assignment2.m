load('assignment2data\compEx1data.mat');
%%
% Exercise 1
% Plot 3D points
axis equal;
plot3(X(1, :), X(2,:), X(3,:), '.', 'MarkerSize', .8);
hold on;
plotcams(P);
%%
% Prepare image 1 and project into camera 1
x1 = P{1}*X;
x1 = x1(1:end-1, :)./x1(end, :);
vis1 = isfinite(x{1}(1, :));
im1 = imread(imfiles{1});
%Plot image 1 and the projected points
imagesc(im1);
hold on;
axis equal;
plot(x1(1, vis1), x1(2, vis1), 'r.', 'MarkerSize', .8);
plot(x{1}(1, vis1), x{1}(2, vis1), 'b.', 'MarkerSize', .8);

%%
% Create Projective tranformation matrices
T1 = [1 0 0 0; 0 4 0 0; 0 0 1 0; .1 .1 0 1];
T2 = [1 0 0 0; 0 1 0 0; 0 0 1 0; 1/16 1/16 0 1];
% Project 3d points 
proj1 = T1*X;
proj2 = T2*X;
% Create homogeneous coordinates by dividing by fourth coordinate
proj1 = proj1(1:end, :)./proj1(end, :);
proj2 = proj2(1:end, :)./proj2(end, :);
% Plot 3d points after both projections
figure
plot3(proj1(1, :),proj1(2, :), proj1(3, :), '.', 'MarkerSize', .8); 
hold on;
axis equal;
plotcams(P);
figure
plot3(proj2(1, :),proj2(2, :), proj2(3, :), '.', 'MarkerSize', .8); 
hold on;
axis equal;
plotcams(P);

figure
plot3(proj1(1, :),proj1(2, :), proj1(3, :), '.', 'MarkerSize', .8);
hold on;
plot3(proj2(1, :),proj2(2, :), proj2(3, :), '.', 'MarkerSize', .8); 
plot3(X(1, :), X(2,:), X(3,:), '.', 'MarkerSize', .8);

axis equal;
plotcams(P);


%%
% Projecting the transformed 3D points into camera 1
xproj1 = P{1}*proj1;
xproj2 = P{1}*proj2;
% Create homogeneous coordinates by dividing by third coordinate
xproj1 = xproj1(1:end, :)./xproj1(end, :);
xproj2 = xproj2(1:end, :)./xproj2(end, :);
% Plot image and points 
figure
imagesc(im1);
hold on;
axis equal;
plot(xproj1(1, vis1), xproj1(2, vis1), 'r.', 'MarkerSize', .8);
plot(x{1}(1, vis1), x{1}(2, vis1), 'b.', 'MarkerSize', .8);
figure
imagesc(im1);
hold on;
axis equal;
plot(xproj2(1, vis1), xproj2(2, vis1), 'r.', 'MarkerSize', .8);
plot(x{1}(1, vis1), x{1}(2, vis1), 'b.', 'MarkerSize', .8);

%%

% Exercise 2
KT1 = rq(P{1}*T1)
KT2 = rq(P{1}*T2)

% Not same tranformation,  aspect ratio is different (decides how it scales in x and y, shape of
% pixels)

%%

% Exercise 3
cube1 = imread('assignment2data\cube1.JPG');
cube2 = imread('assignment2data\cube2.JPG');
load('assignment2data\compEx3data.mat');
meanx1 = mean(x{1}(1,:));
meany1 = mean(x{1}(2,:));
stdx1 = std(x{1}(1,:));
stdy1 = std(x{1}(2,:));
meanx2 = mean(x{2}(1,:));
meany2 = mean(x{2}(2,:));
stdx2 = std(x{2}(1,:));
stdy2 = std(x{2}(2,:));
figure
imagesc(cube1);
axis equal
hold on
plot(x{1}(1, :), x{1}(2, :), 'r*', 'MarkerSize', 5);
plot(0, 0, 'b*', 'MarkerSize', 10);

N1 = [1/stdx1 0 -meanx1/stdx1;
    0 1/stdy1 -meany1/stdy1;
    0 0 1];
N2 = [1/stdx2 0 -meanx2/stdx2;
    0 1/stdy2 -meany2/stdy2;
    0 0 1];
x1n = N1*x{1};
x1n = x1n(1:end, :)./x1n(end, :);
x2n = N2*x{2};
x2n = x2n(1:end, :)./x2n(end, :);
figure
plot(x1n(1, :), -x1n(2, :), 'r*', 'MarkerSize', 5);
axis equal
hold on
plot(0, 0, 'b*', 'MarkerSize', 10);
plot([ x1n(1, startind ); x1n(1, endind )], -[ x1n(2, startind ); x1n(2, endind )], 'b-', 'MarkerSize', 5);


figure
plot3(Xmodel(1,:),Xmodel(2,:), -Xmodel(3,:), 'r*') 
hold on
axis equal
plot3([ Xmodel(1, startind ); Xmodel(1, endind )] ,[ Xmodel(2, startind ); Xmodel(2, endind )] ,-[ Xmodel(3, startind ); Xmodel(3, endind )], 'b-');
%%
% Points needed: 6 (n+11 unknown 3*n equations)
X=[Xmodel;ones(1, 37)];
M1 = zeros(18, 18);
for i = 1:18
    M1(i*3 -2, 1) = X(1,i);
    M1(i*3 -2, 2) = X(2,i);
    M1(i*3 -2, 3) = X(3,i);
    M1(i*3 -2, 4) = X(4,i);
    M1(i*3 -1, 5) = X(1,i);
    M1(i*3 -1, 6) = X(2,i);
    M1(i*3 -1, 7) = X(3,i);
    M1(i*3 -1, 8) = X(4,i);
    M1(i*3 , 9) = X(1,i);
    M1(i*3 , 10) = X(2,i);
    M1(i*3 , 11) = X(3,i);
    M1(i*3 , 12) = X(4,i);
    M1(i*3 -2, i+12) = -x1n(1, i);
    M1(i*3 -1, i+12) = -x1n(2, i);
    M1(i*3 , i+12) = -x1n(3, i);
end
M2 = zeros(18, 18);
for i = 1:18
    M2(i*3 -2, 1) = X(1,i);
    M2(i*3 -2, 2) = X(2,i);
    M2(i*3 -2, 3) = X(3,i);
    M2(i*3 -2, 4) = X(4,i);
    M2(i*3 -1, 5) = X(1,i);
    M2(i*3 -1, 6) = X(2,i);
    M2(i*3 -1, 7) = X(3,i);
    M2(i*3 -1, 8) = X(4,i);
    M2(i*3 , 9) = X(1,i);
    M2(i*3 , 10) = X(2,i);
    M2(i*3 , 11) = X(3,i);
    M2(i*3 , 12) = X(4,i);
    M2(i*3 -2, i+12) = -x2n(1, i);
    M2(i*3 -1, i+12) = -x2n(2, i);
    M2(i*3 , i+12) = -x2n(3, i);
end

[U1,S1,V1] = svd(M1);
[U2,S2,V2] = svd(M2);
v1 = V1(:,end);
v2 = V2(:,end);
min(diag(S1))
norm(M1*v1)
min(diag(S2))
norm(M2*v2)


%%
P1Tilde = reshape (v1(1:12) ,[4 3])';
P1 = N1\P1Tilde;
P2Tilde = reshape (v2(1:12) ,[4 3])';
P2 = N2\P2Tilde;
x1approx = P1*X;
x1approx = x1approx(1:end, :)./x1approx(end, :);
x2approx = P2*X;
x2approx = x2approx(1:end, :)./x2approx(end, :);
figure
imagesc(cube1);
axis equal
hold on
plot(x1approx(1, :), x1approx(2, :), 'r*', 'MarkerSize', 5);
plot(x{1}(1, :), x{1}(2, :), 'g.', 'MarkerSize', 5);

figure
imagesc(cube2);
hold on
axis equal
plot(x2approx(1, :), x2approx(2, :), 'r*', 'MarkerSize', 5);
plot(x{2}(1, :), x{2}(2, :), 'g.', 'MarkerSize', 5);


figure
plot3(Xmodel(1,:),Xmodel(2,:), Xmodel(3,:), 'g.') 
hold on
axis equal
set(gca, 'Zdir', 'reverse');
plot3([ Xmodel(1, startind ); Xmodel(1, endind )] ,[ Xmodel(2, startind ); Xmodel(2, endind )] ,[ Xmodel(3, startind ); Xmodel(3, endind )], 'b-');
plotcams({P1 P2})

kk1 = rq(P1);
kk2 = rq(P2);
kk1 = kk1 ./kk1(3, 3)
kk2 = kk2 ./kk2(3, 3)
% Because we chose the vector "v" so that the cube is in front of the
% camera
%%

% Computer exercise 4
vl_setup()
%%
[f1 d1] = vl_sift(single(rgb2gray(cube1)), 'PeakThresh', 1);
[f2 d2] = vl_sift(single(rgb2gray(cube2)), 'PeakThresh', 1);

figure
imagesc(cube1);
hold on
axis equal
vl_plotframe(f1);


figure
imagesc(cube2);
hold on
axis equal
vl_plotframe(f2);

[matches, scores] = vl_ubcmatch(d1, d2);

x1 = [f1(1, matches (1 ,:)); f1(2, matches (1 ,:))];
x2 = [f2(1, matches (2 ,:)); f2(2, matches (2 ,:))];

perm = randperm( size ( matches ,2));
figure ;
imagesc([cube1 cube2]);
hold on;
plot([x1(1, perm (1:10)); x2(1, perm (1:10))+ size(cube1 ,2)] , [x1(2, perm(1:10)); x2(2, perm(1:10))], '-');
hold off;
%%

% Computer exercise 5

Xt = zeros(4, 1610);
for i = 1:1610
    Mt = [P1 -[x1(:, i);1] [0;0;0]; P2 [0;0;0] -[x2(:, i);1]];
    [Ut,St,Vt] = svd(Mt);
    vt = Vt(:, end);
    Xt(1, i) = vt(1);
    Xt(2, i) = vt(2);
    Xt(3, i) = vt(3);
    Xt(4, i) = vt(4);
end
Xt
Xt = Xt./Xt(end, :);

%%
figure
plot3(Xt(1,:),Xt(2,:), Xt(3,:), 'g.') 
hold on
axis equal
set(gca, 'Zdir', 'reverse');
plotcams({P1 P2})


%%
% Project 3d points 
xproj1 = P1*Xt;
xproj2 = P2*Xt;
% Create homogeneous coordinates by dividing by fourth coordinate
xproj1 = xproj1(1:end, :)./xproj1(end, :);
xproj2 = xproj2(1:end, :)./xproj2(end, :);

% Fetch the points that are good enough
good_points = ( sqrt (sum ((x1 - xproj1 (1:2 ,:)).^2)) < 3 & sqrt (sum ((x2 - xproj2 (1:2 ,:)).^2)) < 3);
Xtn = Xt(:, good_points);

%%
%plot projected points and #D points
figure ;
imagesc([cube1 cube2]);
hold on;
%plot([x1(1, perm (1:10)); x2(1, perm (1:10))+ size(cube1 ,2)] , [x1(2, perm(1:10)); x2(2, perm(1:10))], '-');
plot([xproj1(1, perm (1:10)); xproj2(1, perm (1:10))+ size(cube1 ,2)] , [xproj1(2, perm(1:10)); xproj2(2, perm(1:10))], '-');
hold off;
%%
figure
plot3(Xtn(1,:),Xtn(2,:), Xtn(3,:), 'g.') 
hold on
axis equal
set(gca, 'Zdir', 'reverse');
plot3(Xmodel(1,:),Xmodel(2,:), Xmodel(3,:), 'g.') 
plot3([ Xmodel(1, startind ); Xmodel(1, endind )] ,[ Xmodel(2, startind ); Xmodel(2, endind )] ,[ Xmodel(3, startind ); Xmodel(3, endind )], 'b-');
plotcams({P1 P2})
%%
figure
plot3([ Xmodel(1, startind ); Xmodel(1, endind )] ,[ Xmodel(2, startind ); Xmodel(2, endind )] ,[ Xmodel(3, startind ); Xmodel(3, endind )], 'b-');
hold on
axis equal
set(gca, 'Zdir', 'reverse');
plot3(Xmodel(1,:),Xmodel(2,:), Xmodel(3,:), 'g.') 
plotcams({P1 P2})

%%
p1n = rq(P1)\P1;
p2n = rq(P2)\P2;
% Project 3d points 
xproj1n = p1n*Xt;
xproj2n = p2n*Xt;
% Create homogeneous coordinates by dividing by fourth coordinate
xproj1n = xproj1n(1:end, :)./xproj1n(end, :);
xproj2n = xproj2n(1:end, :)./xproj2n(end, :);

% Fetch the points that are good enough
good_points = ( sqrt (sum ((x1 - xproj1 (1:2 ,:)).^2)) < 3 & sqrt (sum ((x2 - xproj2 (1:2 ,:)).^2)) < 3);
Xtnn = Xt(:, good_points);
%%
%plot projected points and #D points
figure ;
imagesc([cube1 cube2]);
hold on;
%plot([x1(1, perm (1:10)); x2(1, perm (1:10))+ size(cube1 ,2)] , [x1(2, perm(1:10)); x2(2, perm(1:10))], '-');
plot([xproj1n(1, perm (1:10)); xproj2n(1, perm (1:10))+ size(cube1 ,2)] , [xproj1n(2, perm(1:10)); xproj2n(2, perm(1:10))], '-');
hold off;
