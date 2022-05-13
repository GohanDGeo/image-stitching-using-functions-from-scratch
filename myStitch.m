% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1
%
% Function that stitches 2 images. (Can handle rotation and translation,
% but not scale)
% @args:
% im1 -> the first input image
% im2 -> the second input image
% @outputs:
% Im  -> the stitched picture from im1 and im2

function Im=myStitch(im1,im2)

    % First turn both images to grayscale, to detect features
    grayImage = rgb2gray(im1);
    grayImage2 = rgb2gray(im2);

    % Detect corners in the first image, using Harris Corner Detection
    points1 = myDetectHarrisFeatures(grayImage);
    xcoords = points1(:,1);
    ycoords = points1(:,2);

    % Detect corners in the second image, using Harris Corner Detection
    points2 = myDetectHarrisFeatures(grayImage2);
    xcoords2 = points2(:,1);
    ycoords2 = points2(:,2);

    % Extract the descriptors for keypoitns in both images
    features1 = myExtractFeatures(grayImage, xcoords, ycoords,'upgrade');
    features2 = myExtractFeatures(grayImage2, xcoords2, ycoords2,'upgrade');

    % Find 3 matches between the keypoints of the 2 images
    [idx1,idx2] = myMatchFeatures(features1, features2);

    % Get the 3 matching sets of points
    matchedPoints1 = points1(idx1,:);
    matchedPoints2 = points2(idx2,:);

    % Construct a matrix that holds the coordinates of the triangle of the
    % 3 matched points in image 1, in the form of:
    % [p1x p1y 1; p2x p2y 1; p3x p3y 1]
    t1 = [matchedPoints1(1,:); matchedPoints1(2,:); ...
          matchedPoints1(3,:)];
    t1 = [t1 ones(3,1)];

    % Construct a matrix that holds the coordinates of the triangle of the
    % 3 matched points in image 2, in the form of:
    % [p1x p1y 1; p2x p2y 1; p3x p3y 1]
    t2 = [matchedPoints2(1,:); matchedPoints2(2,:); ...
          matchedPoints2(3,:)];
    t2 = [t2 ones(3,1)];

    % If the first matrix <t1> holds a triangle ABC on the first image, and
    % the second matrix <t2> a triangle PQR in the second image, and ABC
    % maps to PQR,then there is a matrix T that performs this
    % tranformation, so ABC * T = PQR. 
    % So this transformation matrix is T = inv(ABC)*PQR
    affinityTf = t1\t2;

    % Since we want the inverse transformation, to go from the triangle PQR
    % (so from the second image) to the triangle ABC (to the first image),
    % we take the inverse of the affine transform matrix
    Tinv =  inv(affinityTf);

    % Then from the inverse transform matrix we find the rotation
    ss = Tinv(2,1);
    sc = Tinv(1,1);
    
    % We can also find the scaling, but this is out of the scope of this
    % excersise 
    %scaleRecovered = sqrt(ss*ss + sc*sc);
    
    % in degrees
    thetaRecovered = atan2(ss,sc)*180/pi;

    % And the translation in both the x and y axis
    tx = Tinv(3,1);
    ty = Tinv(3,2);

    % This flag indicates if <im1> is to the left (flag == 0), or to the
    % right (flag == 1) in the final stitched image
    flag = 0;

    % Rotate the second image in respect to the first
    angle = thetaRecovered;
    rotImg = myImgRotation(im2, angle);
    
    % Get the size of the rotated image
    rotSize = size(rotImg,1,2);


    % The translation <tx>, <ty> found above, is in respect to the pixel
    % p=[1 1] of the rotated image. Since the coordinate system changes
    % when we rotate the image (especially since black borders are added
    % most times), we need to find the rotation offset. To do this, we
    % rotate the pixel p = [1 1] by <angle> degrees counter clockwise (so
    % to the rotated image). This means we find the position of pixel p in
    % the rotated image. Its coordinates are the rotation offset
    start = [1;1];
    rotP = rotatePixel(start, im2, rotImg, angle);
    offset = [start(1) - rotP(1), start(2) - rotP(2)];

    % Add the offset to the translation
    tx = round(tx + offset(1));
    ty = round(ty + offset(2));

    % If the translation in the x axis is negative, this means <im2> has to
    % be to the left of <im1> (since transformations are repective to <im1>
    
    if tx < 0
        %If so, raise the flag, and reverse all translations.
        flag = 1;
        tx = -tx;
        ty = -ty;
    end

    % This is where to start putting the left image in the stitched canvas
    tyog = 1;
    
    % This are the coordinates of where to start putting the right image in
    % the stitched canvas
    tyd = max(ty,1);
    txd = max(tx,1);

    % If the translation in the y axis is negative, this means that the
    % left image will start lower than the right image, thus <tyog> is
    % offset <ty> downwards.
    if ty < 0
        ty = -ty;
        tyog = ty + 2;
    end

    % CASE 1 (flag == 0): <im1> is on the left
    if flag == 0
        
        % The dimensions of the stitched image are the maximum of the
        % dimensions of the image to the left and of the rotated image plus
        % the translation
        height = max(tyd + rotSize(1) - 1, size(im1,1));
        width  = max(txd + rotSize(2) - 1, size(im1,2)); 
        
        % The stitched image dimensions
        panoramaDim = [height, width, size(im1,3)];

        % Create a black canvas for the stitched image
        Im = zeros(panoramaDim, 'like', im1);
        
        % Put the transformed image first, starting from point pIm = [txd
        % tyd] in the stitched image, and put the whole rotated image in
        % the canvas.
        Im(tyd:rotSize(1)+tyd-1, txd:rotSize(2)+txd-1,:) = ...
            rotImg(:,:,:);

        % Put the non-transformed image to the left, to overlap over the
        % transformed image (that way any black borders that might happen
        % from rotation are covered. The start position of the left image
        % on the y axis depends on whether the translation in the y axis of
        % the transformed image is negative. (In the x axis it's always at
        % the beginning. If <tx> was negative we would go in case 2)
        Im(tyog:size(im1,1)+tyog-1,1:size(im1,2),:) = im1(:,:,:);
    
    % CASE 1 (flag == 0): <im1> is on the right
    else
        % The dimensions of the stitched image are the maximum of the
        % dimensions of the image to the right plus translations and of the
        % rotated image. This is because we start the coordinate system
        % based on the image to the left, thus in this case the rotated
        % image.
        height = max(tyd + size(im1,1)-1, rotSize(1));
        width  = max(txd + size(im1,2)-1, rotSize(2)); 
        
        % The stitched image dimensions
        panoramaDim = [height, width, size(im1,3)]; 
        
        % Create a black canvas for the stitched image
        Im = zeros(panoramaDim, 'like', im1);

        % Put the transformed image first, starting from point pIm = [1
        % 1] in the stitched image, and put the whole rotated image in
        % the canvas. This is because the image to the left will always be
        % put in the leftmost position (thus x=1), and <tyog> accounts for
        % any offset in the y axis (if the other image is "taller" than
        % this one)
        Im(tyog:size(rotImg,1)+tyog-1,1:size(rotImg,2),:) = rotImg(:,:,:);
        
        % Put the non-transformed image to the right, to overlap over the
        % transformed image (that way any black borders that might happen
        % from rotation are covered. The start position in the canvas
        % depends on the translation (as the right image is the one that is
        % translated, since we always star the axis with respect to the
        % left image)
        Im(tyd:size(im1,1)+tyd-1, txd:size(im1,2)+txd-1,:) = ...
        im1(:,:,:);
    end
end
