% Exercise 1

compEx1 = open('assignment1data\compEx1.mat');
x2D = compEx1.x2D;
x3D = compEx1.x3D;
flatMat2D = pflat(x2D);
flatMat3D = pflat(x3D);
plot(flatMat2D(1, :), flatMat2D(2, :), '.');
figure;
plot3(flatMat3D(1, :), flatMat3D(2, :), flatMat3D(3, :), '.');


%%
% Exercise 2
image = imread('assignment1data\compEx2.JPG');
imagesc(image);
colormap gray;
hold on;
compEx2 = open('assignment1data\compEx2.mat');
points = [compEx2.p1 compEx2.p2 compEx2.p3];
for i = 1:2:length(points)
    p1 = points(1:3, i);
    p2 = points(1:3, i+1);
    plot(p1(1), p1(2), 'g*');
    hold on;
    plot(p2(1), p2(2), 'g*');
    hold on;   
end
lines = [linsolve([points(1:3, 1).'; points(1:3, 2).'; 0, 0, 1],[0, 0, 1].'),linsolve([points(1:3, 3).'; points(1:3, 4).'; 0, 0, 1],[0, 0, 1].'),linsolve([points(1:3, 5).'; points(1:3, 6).'; 0, 0, 1],[0, 0, 1].')];
rital(lines(1:3,1));
hold on;
rital(lines(1:3,2));
hold on;
rital(lines(1:3,3));
hold on;
int23 =linsolve([lines(1:3, 2).'; lines(1:3, 3).'; 0, 0, 1], [0, 0, 1].');
plot(int23(1), int23(2), 'b*')
hold on
distanceToLine = abs(lines(1, 1)*int23(1) + lines(2,1)*int23(2)+lines(3, 1))/sqrt(lines(1, 1)^2 + lines(2, 1)^2)
% 8.2695 Not really close to zero, since the lines are so "far away" the
% distance between them in 3d might be much more than it looks on the 2d
% representation

%%
% Exercise 3

compEx3 = open('assignment1data\compEx3.mat');
sp = compEx3.startpoints;
ep = compEx3.endpoints;
plot([sp(1, :); ep(1, :)], [sp(2, :); ep(2, :)], 'black-');
hold on;
axis equal;
H1 = [sqrt(3), -1, 1;1, sqrt(3), 1;0, 0, 2];
H2 = [1, -1, 1;1, 1, 0;0, 0, 1];
H3 = [1, 1, 0;0, 2, 0;0, 0, 1];
H4 = [sqrt(3), -1, 1;1, sqrt(3), 1;1/4, 1/2, 2];

spH = [sp(1, :);sp(2,:) ;ones(1, 42)];
epH = [ep(1, :);ep(2,:) ;ones(1, 42)];
H1sp = pflat(H1*spH);
H1ep = pflat(H1*epH);
figure;
axis equal;
plot([H1sp(1, :); H1ep(1, :)], [H1sp(2, :); H1ep(2, :)], 'black-');
title('H1');
H2sp = pflat(H2*spH);
H2ep = pflat(H2*epH);
figure;
axis equal;
plot([H2sp(1, :); H2ep(1, :)], [H2sp(2, :); H2ep(2, :)], 'black-');
title('H2');
H3sp = pflat(H3*spH);
H3ep = pflat(H3*epH);
figure;
axis equal;
plot([H3sp(1, :); H3ep(1, :)], [H3sp(2, :); H3ep(2, :)], 'black-');
title('H3');
H4sp = pflat(H4*spH);
H4ep = pflat(H4*epH);
figure;
axis equal;
plot([H4sp(1, :); H4ep(1, :)], [H4sp(2, :); H4ep(2, :)], 'black-');
title('H4');

% Preserve length between points when scaling = 1 --> H3 and H2
% Preserve angles between lines : Similarity, Eucledian H1, H2
% Maps parallel lines to parallel lines: Affine, H3

% Affine : H3
%Similarity: H1
% Eucledian: H2
% Projective: H4


%%
% Exercise 4
compEx4 = open('assignment1data\compEx4.mat');
P1 = compEx4.P1;
P2 = compEx4.P2;
pm = compEx4.U;
C1 = null(P1);
C1 = C1 ./ C1(4);
C2 = null(P2);
C2 = C2 ./ C2(4);
pmC = pflat(pm);
plot3(pmC(1,:), pmC(2,:), pmC(3, :), '.');
title('3D with cameras and direction');
hold on;
plot3(C1(1), C1(2), C1(3), 'g*');
hold on;
plot3(C2(1), C2(2), C2(3), 'b*');
hold on

v1 = det(P1(:,1:3)).*P1(3,1:3);
v2 = det(P2(:, 1:3)).*P2(3,1:3);
v1 = v1 / norm(v1);
v2 = v2 / norm(v2);
quiver3(C1(1), C1(2), C1(3), v1(1), v1(2), v1(3), 4);
hold on;
quiver3(C2(1), C2(2), C2(3), v2(1), v2(2), v2(3), 4);
hold on;
projP1 = pflat(P1*pm);
projP2 = pflat(P2*pm);
image1 = imread('assignment1data\compEx4im1.JPG');
image2 = imread('assignment1data\compEx4im2.JPG');
figure;
imagesc(image1);
colormap gray;
hold on;
plot(projP1(1, :), projP1(2, :), '.')
title('Camera 1');
figure;
imagesc(image2);
colormap gray;
hold on;
plot(projP2(1, :), projP2(2, :), '.')
title('Camera 2');

% After alot of tinkering it does look reasonable
