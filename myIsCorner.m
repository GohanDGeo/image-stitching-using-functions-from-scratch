% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1
% Function that returns if a corner at position <p> belongs in a corner
% region.
% @args:
% Sxx    -> the Ix.*Ix product (Ix is the x gradient of the image),
%           after being convolved with a Gaussian window
% Syy    -> the Iy.*Iy product (Iy is the y gradient of the image), 
%           after being convolved with a Gaussian window
% Sxy    -> the Ix.*Iy product (Ix, Iy are the x,y gradient of the image
%           respectively), after being convolved with a Gaussian window
% k      -> a constant used in the Harris Corner Detection algorithm
% Rthres -> if a pixel's R value is above this threshold it is considered a
%           corner
% @outputs:
% c      -> a boolean value that is 1 (true) if the pixel p is a corner, 
%           0 (false) otherwise
function c = myIsCorner(Sxx, Syy, Sxy, p, k, Rthres)

    % Get size of image
    [h,w] = size(Sxx);
    
    % Assign a window size, to determine the neighborhood of the pixel
    winSize = 3;
    
    % Get pixel's coordinates
    x = p(1);
    y = p(2);
   
    % Get half of the window size, to determine the window in the
    % gradient/gaussin image
    winH = floor(winSize/2);
    
    % Make a mesh grid of size winSize x winSize around the pixel
    xwin = (max(x-winH,1):min(x+winH,w));
    ywin = (max(y-winH,1):min(y+winH,h));
    
    % And get this window region in all Sxx, Sxy, Syy
    [xx,yy] = meshgrid(xwin, ywin);
    Sxx = Sxx(sub2ind(size(Sxx), yy, xx));
    Sxy = Sxy(sub2ind(size(Sxy), yy, xx));
    Syy = Syy(sub2ind(size(Syy), yy, xx));
    
    % Get the central pixel in the window (which is the pixel we are trying
    % to find if it is a corner or not)
    x = ceil(winSize/2);
    y = x;
    
    % Create the M matrix of the Harris Corner Detection Algorithm
    % Both versions are acceptable, where one sums over all elements of the
    % respective matrices, to get the values of M (the one used), where the
    % other uses the specific pixel's Sxx,Sxy,Syy values as M's elements.
    % (if the latter is used, the threshold Rthres has to change.
    
    %M = [Sxx(y,x) Sxy(y,x); Sxy(y,x) Syy(y,x)];
    M = [sum(Sxx(:)) sum(Sxy(:)); sum(Sxy(:)) sum(Syy(:))];

    % Calculate the value R of the pixel 
    R = det(M) - k*trace(M)^2;
    
    % And determine if it is a corner
    c = R > Rthres;

end


