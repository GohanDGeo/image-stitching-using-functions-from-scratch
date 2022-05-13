% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1

% Function that returns a descriptor vector <d> for a pixel <p> in image
% <I>, based on the SIFT descriptor
% @args:
% I -> the image
% p -> pixel's coordinates
% @outputs:
% d -> a column vector describing the pixel at position <p>

function d = naiveSIFT(I,p)
   
    % Get size of image
    [rows, cols, ~] = size(I);
    
    % Get coordinats of the points
    xp = round(p(1));
    yp = round(p(2));
    
    % Set the number of bins
    bins = 36;
    
    % Get the degree range in each bin
    fac = 360/bins;
    
    % Set the grid/window size to use
    winSize = 9;
    
    winw = floor(winSize/2);
    winWidth = [-winw:winw];
    
    % Create a matrix of 9xbins that holds the bins for each of the 9 sub
    % grids
    hCells = zeros(9,bins);
    
    % The histogram of the pixel's neighbor
    H = zeros(1,bins);
    
    % Gaussian weight function
    z = fspecial('gaussian', [4 4], 9);
    
    if xp + (winw*2) > cols | yp + (winw*2) > rows | xp - (winw*2) < 2 | yp - (winw*2) < 1
        d = [];
    else

        % For a 5x5 neighbor find the dominant gradient orientation
        for r=-2:2
            for c=-2:2
                x = xp + c;
                y = yp + r;
                
                % Get gradient in both x and y directions
                dy = I(y+1,x) - I(y-1,x);
                dx = I(y, x+1) - I(y, x-1);
                
                % Get the gradient's magnitude
                m = sqrt(dx^2 + dy^2);
                
                % Normalize angle to 0-360 degrees
                theta = atan2d(dy,dx);
                theta = (theta<0)*360 + theta;
                
                if ~isnan(theta)
                    if theta == 360
                        theta = 0;
                    end
                    
                    % Find the bin the angle should go to
                    binIdx = floor(theta/fac) + 1;
                    
                    % Append to the bin factored by the magnitude*gaussian
                    % weight
                    H(binIdx) = H(binIdx) +  m*z(mod(r,4)+1,mod(c,4)+1);
                end
            end
        end
        
        % Find the dominant orientation
        [~, maxIdx] = max(H);
        angle_offset  = maxIdx*fac;
        
        % Make center of rotation the pixel of interest
        cent = [xp;yp];
        
        if( size(p,1)== 1)
            p = p';
        end
        
        % Set the rotation matrix
        tfMat = [cosd(angle_offset), -sind(angle_offset); ...
                        sind(angle_offset) cosd(angle_offset)];
        
        % For a 9 by 9 grid, create 3x3 sub-grids of 3x3 pixels, and find
        % their histograms, like above.
        for r=winWidth
            for c=winWidth
                x = xp + c;
                y = yp + r;
                
                
                % The 9x9 grid is rotated according to the dominant
                % orientation to achieve rotation invariance
                currp = [x;y];
                rotP = tfMat*(currp-cent)+cent;
                rotP = round(rotP);
                
                xrot = rotP(1);
                yrot = rotP(2);

                % Also rotate the neighbors of the pixel of interest
                pdy1 = round(tfMat*([x;y+1]-p)+p);
                pdy2 =  round(tfMat*([x;y-1]-p)+p);

                pdx1 = round(tfMat*([x+1;y]-p)+p);
                pdx2 =  round(tfMat*([x-1;y]-p)+p);

                % Get the magnitude and theta
                dy = I(pdy1(2),pdy1(1)) - I(pdy2(2), pdy2(1));
                dx = I(pdx1(2),pdx1(1)) - I(pdx2(2), pdx2(1));
                m = sqrt(dx^2 + dy^2);
                theta = atan2d(dy,dx);
                theta = (theta<0)*360 + theta;
                if ~isnan(theta)
                    % Determine which of the 3x3 blocks the pixel belongs
                    % to
                    if (-4 <= r) & (r <= -2) & (-4 <= c)& (c <= -2)
                        hidx = 1;                      
                    elseif (-4 <= r) & (r <= -2) & (-1 <= c) & (c <= 1)
                        hidx = 2;
                    elseif (-4 <= r) & (r <= -2) & 2 <= c
                        hidx = 3; 
                    elseif (-1 <= r) & (r <= 1) & (-4 <= c)& (c <= -2)
                        hidx = 4;                      
                    elseif(-1 <= r) & (r <= 1) &  (-1 <= c) & (c <= 1)
                        hidx = 5;
                    elseif (-1 <= r) & (r <= 1) & 2 <= c
                        hidx = 6;

                    elseif 2 <= r  & (-4 <= c) & (c <= -2)
                        hidx = 7;                      
                    elseif 2 <=r  & (-1 <= c) & (c <= 1)
                        hidx = 8;
                    else
                        hidx = 9;
                    end
                    
                    if theta == 360
                        theta = 0;
                    end
                    
                    % Append to histogram
                    binIdx = floor(theta/fac) + 1;
                    hCells(hidx,binIdx) = hCells(hidx,binIdx)+m*z(mod(r,4)+1,mod(c,4)+1);
                end
            end
        end

        % Now let <d> be a concatation of the histograms of each of the 3x3
        % grids, so it will be 3x3x36 in size
        d = reshape(hCells',[],1);
        
        % Set max to 0.2 and normalize, to prevent being affected by
        % brightness and contrast
        d = min(0.2,d);
        mag = norm(d);
        d = d/mag;
    end
end