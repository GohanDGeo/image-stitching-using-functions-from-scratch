% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1
%
% Function that calculates the pixel's <p> bilinear interpoloation (as
% deascribed in this excersise), in image <I>
% @args:
% p      -> the pixel to found inteprolated value for
% I         -> the image the pixel belongs in
% rotImg -> the image that would result from the rotation
% angle  -> the rotation angle in degrees
% @output:
% px     -> the intrpolated pixel's value

function px = bilinearInterpolation(I, p)
    
    x = p(1);
    y = p(2);
    
    
    [rows, cols, ~] = size(I);
    
    % Check if each neighbor exists, and take the mean depending on the
    % number of neighbors
    pxVal = [];
    if y - 1 > 0
        pxVal = [pxVal; I(y-1, x, :)];
    end

    if x - 1 > 0
        pxVal = [pxVal; I(y, x - 1, :)];
    end

    if y + 1 <= rows
        pxVal = [pxVal; I(y+1, x, :)];
    end

    if x + 1 <= cols
        pxVal = [pxVal; I(y, x + 1, :)];
    end
    
    %pxVal = [I(max(y-1,1), x, :) I(y, max(x - 1,1), :)...
    %        I(min(y+1,rows), x, :) I(y, min(x + 1,cols), :)];
    px = mean(pxVal);
end