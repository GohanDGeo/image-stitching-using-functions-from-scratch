function c = isCorner(I, p, k, Rthres)


    [h,w] = size(I);
    winSize = 3;
    sigma = 1;
    gSize = 3;
    g=fspecial('gaussian', gSize, sigma); 

    maskx = [1 0 -1; 1 0 -1; 1 0 -1];
    masky = [1 1 1; 0 0 0; -1 -1 -1];

    x = p(1);
    y = p(2);

    winH = floor(winSize/2);
    xwin = (max(x-winH,1):min(x+winH,w));
    ywin = (max(y-winH,1):min(y+winH,h));

    [xx,yy] = meshgrid(xwin, ywin);
    subImg = I(sub2ind(size(I), yy, xx));
    
    Ix = conv2(subImg, maskx, 'same');
    Iy = conv2(subImg, masky, 'same');

    Ixx = Ix.^2;
    Iyy = Iy.^2;
    Ixy = Ix.*Iy;
    

    Sxx = conv2(Ixx, g, 'same');
    Syy = conv2(Iyy, g, 'same');
    Sxy = conv2(Ixy, g, 'same');
    
    x = ceil(winSize/2);
    y = x;
    M = [Sxx(y,x) Sxy(y,x); Sxy(y,x) Syy(y,x)];
    %M = [sum(Sxx(:)) sum(Sxy(:)); sum(Sxy(:)) sum(Syy(:))];
    R = det(M) - k*trace(M)^2;
    c = R > Rthres;
end


