% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1

% Function that returns the corners detected by using Harris' Corner
% Detection algorithm, in an image <I>
% @args:
% I -> the image
% @outputs:
% corners -> a matrix containing two columns, with the coordinates of the
% detected corners
function corners = myDetectHarrisFeatures(I)

    %Get the size of the image
    [rows, cols] = size(I);
    
    %Set the constant k (Set to 0.05 after trial and error)
    k = 0.05;
    
    %Set the threshold for the value R (Set to 5 after trial and error)
    Rthres = 5;
    %Rthres = 5.8;
    %Cast the image to double
    I=im2double(I);

    %Arrays to hold the coordiantes of the corners
    xcoords = [];
    ycoords = [];

    %These masks produce the gradient in the x and y direction
    %respectively.
    maskx = [1 0 -1; 1 0 -1; 1 0 -1];
    masky = [1 1 1; 0 0 0; -1 -1 -1];
    
    %Convolve the image with the above masks to produce the gradient of the
    %image in both directions
    Ix = conv2(I, maskx, 'same');
    Iy = conv2(I, masky, 'same');
    
    %Get the required gradient products
    Ixx = Ix.^2;
    Iyy = Iy.^2;
    Ixy = Ix.*Iy;
    
    %Set the parameters for the Gaussian window
    sigma = 1;
    gSize = 3;
    g=fspecial('gaussian', gSize, sigma); 

    %Convolve the gradient products with the gaussian window
    Sxx = conv2(Ixx, g, 'same');
    Syy = conv2(Iyy, g, 'same');
    Sxy = conv2(Ixy, g, 'same');

    R = [];
    %And now iterate over the whole image, to detect corners.
    %Begin at an offset of 3 in both directions, as to calculate the R
    %value of a pixel, a window of size 3x3 is used
    for y=3:rows-2
        for x=3:cols-2
            p = [x, y];
            %Run the function myIsCorner (or isCorner) to get if a pixel
            %belongs in a corner
            %iscorner = isCorner(I, p, k, Rthres); 

            iscorner = myIsCorner(Sxx, Syy, Sxy, p, k, Rthres);
            if iscorner 
                %If it is a corner, append its position to the respective
                %vectors.
                xcoords = [xcoords x];
                ycoords = [ycoords y];
            end
        end
    end
    
    %Construct the corners vector
    corners = [xcoords' ycoords'];
end

