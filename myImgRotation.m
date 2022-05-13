% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1

% Function that rotates input image by <angle> degrees counter-clockwise.
% @args:
% img -> the image to rotate
% angle -> the angle to rotate the image by
% @outputs:
% rotImg -> the rotated image
function [rotImg] = myImgRotation(img , angle)

    %Get the size of the image
    [rows, cols, channels] = size(img);

    %Construct a rotation matrix. This matrix performs the inverse rotation
    %of a point p=[x;y], where the point would have been rotated by <angle>
    %degrees counter clockwise (so it rotates <angle> degrees clockwise)
    %NOTE: For this matrix to be a clockwise rotation, it must be applied
    %like this: rotatedPoint = [x,y]*tfMat
    tfMat = [cosd(angle), sind(angle); -sind(angle) cosd(angle)];

    %Rotate the extreme point p=[cols;rows] by angle, to get the maximum
    %dimensions needed to hold the rotated image
    yMax = floor(rows*abs(cosd(angle)) + cols*abs(sind(angle)));
    xMax = floor(rows*abs(sind(angle)) + cols*abs(cosd(angle)));

    %Create a black image with the rotated img dimensions. The rotate image
    %has the same number of channels as the original
    rotImgDims = [yMax xMax channels];
    
    %Get the rotated image's center. This is the cente of the inverse
    %rotation performed.
    rotmidx = (xMax/2);
    rotmidy = (yMax/2);

    %Get the original image's center. This will be the center of original 
    %rotation.
    ogmidx = (cols/2);
    ogmidy = (rows/2);

    % VECTORIZED implementation of image rotation.
    
    %This matrix is used to apply the interpolation that is described in
    %this excersise. Contrary to the usual bilinear interpolation, this
    %bilinear interpolation suggested, mostly acts as a smoothing filter on
    %the image.
    c = [0 1 0; 1 0 1; 0 1 0];
    
    %Convolute the matrix c with the image img, and then divivde by the
    %number of neighbors each point has. This will result in an image
    %<interpImg> where each pixel is interpolated as described in this
    %exercise. In essence, by convolving with the matrix <c>, the value of
    %each pixel becomes the sum of its orthogonal neighbors, and by dividng
    %with the next convolution matrix (which convolves an array of 1s with
    %the matrix <c>, resulting in a matrix that holds the number of
    %neighbors of each pixel), the desired interpolation is done.
    interpImg = convn(img,c, 'same')./ ...
                convn(ones(rows, cols), c, 'same');
            
    %Cast the <interpImg> as uint8
    interpImg = uint8(interpImg);
     
    %Create a grid (mesh grid) of the coordinates of the rotated image,
    %subtracting the center of the rotaed image, as to perform the rotation
    %around that center
    Y = (1:yMax) - rotmidy;
    X = (1:xMax) - rotmidx;

    [X, Y] = meshgrid(X, Y);
    points = [X(:), Y(:)];

    %Perform the inverse rotation, which means that for a point p'=[x' y']
    %in the rotated image, we find the point p=[x y] in the original image.
    %This way, each point p'=[x' y'] of the rotated image is mapped to a
    %point p=[x y] in the original image.
    
    %The center of the original image is added to have the new coordinates
    %relative to that image
    coords = (points*tfMat);
    coords(:,1) = coords(:,1) + ogmidx;
    coords(:,2) = coords(:,2) + ogmidy;
    
    %The coordinates are floor'd as mentioned in the excersise
    x = floor(coords(:,1));
    y = floor(coords(:,2));
    
    %We then find all coordinates that are out of bounds in the original
    %image, as a result of the rotation of the coordinates of the rotated
    %image
    outbound = y < 1| y > rows | x < 1 | x > cols;
    
    %Cap all outbound coordinates to the min and max of the original image.
    %This is a placeholder as these entries will later be changed to black
    x(x<1) = 1; x(x>cols) = cols;
    y(y<1) = 1; y(y>rows) = rows;
    
    %Create an array to use later in sub2ind, so as to fill all channels
    %If the image has 3 channels, and dimensions 10x10, this array will
    %have 100 entries with 1s, followed by 100 entries of 2s and 100
    %entries of 3s. This way each channel/dimension of the image will be
    %filled.
    zout = repelem((1:channels), yMax*xMax)';

    %Repeat the x and y coordinates <channel> times, so to fill all
    %dimensions of the image. (If the image is RGB for example, you need to
    %repeat the coordinates 3 times, to fill all red, green and blue
    %channels.
    x = repmat(x, channels, 1);
    y = repmat(y, channels, 1);

    %Map the rotated (back to the original image) coordinates to the
    %rotated image, using the <interpImg> created earlier. By using sub2ind
    %the coordinates y,x are mapped to the rotated image, from the 
    %interpolated image. zout makes it so this is repeated for all channels
    
    rotImg = interpImg(sub2ind(size(interpImg), y, x, zout));

    %Reshape the <rotImg> to the dimensions it should have
    rotImg = reshape(rotImg, rotImgDims);
    
    %And then turn all pixels that were out bound in the original image, to
    %black
    rotImg(repmat(outbound, [1 1 channels])) = 0;

    %Cast to uint8 to be able to show the image
    rotImg = uint8(rotImg);
    
    
    
    
    
    %NON VECTORIZED VERSION, much slower to run
    %{
    %Create an image of size rotImgDims, as calculated above
    rotImg = zeros(rotImgDims, class(img));
    
    %For each pixel in the rotated image, find the corresponding image in
    %the original image. If it is not out of bounds, the rotated image's
    %value is the interpolated value of the original pixel.
    
    for y=1:yMax
        for x=1:xMax
            coords = [x-rotmidx y-rotmidy]*tfMat;

            yog = floor(coords(2) + ogmidy);
            xog = floor(coords(1) + ogmidx);

            if yog > 0 && yog <= rows && xog > 0 && xog <= cols
                rotImg(y,x,:) = bilinearInterpolation(img, [xog, yog]);
            end
        end
    end
    %}
    
end