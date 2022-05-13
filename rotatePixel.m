% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1
%
% Function that rotates a pixel <p> in image <img> by <angle> degrees 
% coutner-clockwise.
% @args:
% p      -> the pixel to be rotated
% img    -> the image the pixel belongs in
% rotImg -> the image that would result from the rotation
% angle  -> the rotation angle in degrees
% @output:
% rotP   -> the coordinates of the rotated pixel

function rotP = rotatePixel(p, img, rotImg, angle)
    
    %Make <p> a column vector if not already
    if size(p,1) == 1
        p = p';
    end
    
    %Get the center of the original image and the rotated image
    imgSize = size(img,1,2);
    rotSize = size(rotImg,1,2);
    ogCenter = [imgSize(2)/2; imgSize(1)/2];
    rotCenter = [rotSize(2)/2; rotSize(1)/2];

    %The rotation matrix to rotate by <angle> degrees counter clockwise
    tfMat = [cosd(angle) sind(angle); -sind(angle) cosd(angle)];

    %Rotate the pixel counter clockwise, with the center the center of the
    %original image, and then add the rotated image's center to get the
    %coordinates of the pixel in the new image
    rotP = tfMat*(p-ogCenter)+rotCenter;
    
    %Round in case of decimal after rotation
    rotP = round(rotP);
end