% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1

% Main program to run to show the results required.
close all
clear 
clc

%% Load Images
im1 = imread('TestIm1.png');
im2 = imread('TestIm2.png');

%% 1.1.1 Rotate Image
theta1 = 35;
theta2 = 222;

rotIm1theta1 = myImgRotation(im1, theta1);
rotIm1theta2 = myImgRotation(im1, theta2);

%% 1.1.1 Show Images
figure;
imshow(im1);
title("Original TestIm1");

figure;
imshow(rotIm1theta1);
title(sprintf("TestIm1 rotated by %d degrees",theta1));

figure;
imshow(rotIm1theta2);
title(sprintf("TestIm1 rotated by %d degrees",theta2));

%% 1.2.1 Make gray images and rotate points
grayIm1 = rgb2gray(im1);
grayRotIm1theta1 = rgb2gray(rotIm1theta1);
grayRotIm1theta2 = rgb2gray(rotIm1theta2);

grayIm1 = im2double(grayIm1);
grayRotIm1theta1 = im2double(grayRotIm1theta1);
grayRotIm1theta2 = im2double(grayRotIm1theta2);

rhom = 5;
rhoM = 20;
rhostep = 1;
N = 8;

q1 = [200, 200];
q2 = [202, 202];

p = [100, 100];
rotPtheta1 = rotatePixel(p, im1, rotIm1theta1, theta1);
rotPtheta2 = rotatePixel(p, im1, rotIm1theta2, theta2);

%% 1.2.1 Run basic descriptor
dp = myLocalDescriptor(grayIm1, p, rhom, rhoM, rhostep, N);

drotPtheta1 = myLocalDescriptor(grayRotIm1theta1, rotPtheta1, ...
              rhom, rhoM, rhostep, N);
drotPtheta2 = myLocalDescriptor(grayRotIm1theta2, rotPtheta2, ...
  rhom, rhoM, rhostep, N);

dq1 = myLocalDescriptor(grayIm1, q1, rhom, rhoM, rhostep, N);
dq2 = myLocalDescriptor(grayIm1, q2, rhom, rhoM, rhostep, N);

fprintf("\nDescriptor for p = [%d, %d] in im1:\n", p(1), p(2));
dp

fprintf("\nDescriptor for p = [%d, %d] in im1 rotated by %d:\n", ...
         rotPtheta1(1), rotPtheta1(2), theta1);
drotPtheta1

fprintf("\nDescriptor for p = [%d, %d] in im1 rotated by %d:\n", ...
         rotPtheta2(1), rotPtheta2(2), theta2);
drotPtheta2

fprintf("\nDescriptor for q1 = [%d, %d] in im1:\n", q1(1), q1(2));
dq1

fprintf("\nDescriptor for q2 = [%d, %d] in im1:\n", q2(1), q2(2));
dq2

%% 1.2.1 Run upgraded descriptor
grayIm1Blur = imgaussfilt(grayIm1,1);
dpup = myLocalDescriptorUpgrade(grayIm1Blur, p, rhom, rhoM, rhostep, N);

grayRotIm1theta1Blur = imgaussfilt(grayRotIm1theta1,1);
drotPtheta1up = myLocalDescriptorUpgrade(grayRotIm1theta1Blur, rotPtheta1, ...
              rhom, rhoM, rhostep, N);
          
grayRotIm1theta2Blur = imgaussfilt(grayRotIm1theta2,1);         
drotPtheta2up = myLocalDescriptorUpgrade(grayRotIm1theta2Blur, rotPtheta2, ...
  rhom, rhoM, rhostep, N);

dq1up = myLocalDescriptorUpgrade(grayIm1Blur, q1, rhom, rhoM, rhostep, N);
dq2up = myLocalDescriptorUpgrade(grayIm1Blur, q2, rhom, rhoM, rhostep, N);

fprintf("\nUpgraded Descriptor for p = [%d, %d] in im1:\n", p(1), p(2));
dpup

fprintf("\nUpgraded Descriptor for p1 = [%d, %d] in im1 (p rotated by %d):\n", ...
         rotPtheta1(1), rotPtheta1(2), theta1);
drotPtheta1up

fprintf("\nUpgraded Descriptor for p2 = [%d, %d] in im1 (p rotated by %d):\n", ...
         rotPtheta2(1), rotPtheta2(2), theta2);
drotPtheta2up

fprintf("\nUpgraded Descriptor for q1 = [%d, %d] in im1:\n", q1(1), q1(2));
dq1up

fprintf("\nUpgraded Descriptor for q2 = [%d, %d] in im1:\n", q2(1), q2(2));
dq2up

%% 1.2.1 Naive Sift
grayIm1BlurSIFT = imgaussfilt(grayIm1,8/3);

dpup = naiveSIFT(grayIm1BlurSIFT, p);

grayRotIm1theta1SIFT = imgaussfilt(grayRotIm1theta1,1);
drotPtheta1up = naiveSIFT(grayRotIm1theta1SIFT, rotPtheta1);
             
          
grayRotIm1theta2SIFT = imgaussfilt(grayRotIm1theta2,1);         
drotPtheta2up = naiveSIFT(grayRotIm1theta2SIFT, rotPtheta2);

%% 1.3.1 Get corners from Harris Corner Detector
corners = myDetectHarrisFeatures(grayIm1);

%% 1.3.1 Plot corners
numcorners = size(corners,1);

width = 5;

figure;
imshow(grayIm1);
hold on

for i=1:numcorners
    % Get upper left corner
    x = corners(i,1) - 2;
    y = corners(i,2) - 2;
    
    rectangle("Position", [x y width width], "EdgeColor", 'r');
end
title("Harris Corner Detection on TestIm1");

%% 2 Stitch the images together
stitchedIm = myStitch(im1, im2);

figure;
imshow(stitchedIm);
title("Stitched image from TestIm1, TestIm2");






