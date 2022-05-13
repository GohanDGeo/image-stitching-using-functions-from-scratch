% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1

% Function that returns a descriptor vector <d> for a pixel <p> in image
% <I>
% @args:
% I -> the image
% p -> pixel's coordinates
% rhom -> minimum radius of neighborhood
% rhoM -> maximum radius of neighborhood
% rhostep -> radius step for the neighborhood
% N -> number of pixels to get in a circle
% @outputs:
% d -> a column vector describing the pixel at position <p>
function d = myLocalDescriptorUpgrade(I,p,rhom ,rhoM ,rhostep ,N)
   
    % The same logic as the original patch descriptor is used.
    % The difference is that here a gaussian filtered image is passed and
    % the feature vector is normalized.
    
    [rows, cols, ~] = size(I);
    
    rhos = rhom:rhostep:rhoM;
    xp = floor(p(1));
    yp = floor(p(2));
    if xp + (rhoM) > cols | yp + (rhoM) > rows | xp - (rhoM) < 1 | yp - (rhoM) < 1
        d = [];
    else
        d = zeros(1, length(rhos));
        dcount = 1;
        for r=rhos
            x = xp;
            y = yp - r;

            rhovec = zeros(1, N);
            rhoveccount = 0;
            for n=1:N

                angle = (2*pi/N) * n;
                
                tfMat = [cos(angle), sin(angle); -sin(angle) cos(angle)];

                coords = [y-yp x-xp]*tfMat;
                xrot = round(coords(2)) + xp;
                yrot = round(coords(1)) + yp;

                rhoveccount = rhoveccount + 1;
                rhovec(rhoveccount) = bilinearInterpolation(I, [xrot, yrot]);

                
            end
            d(dcount) = mean(rhovec(1:rhoveccount));
            dcount = dcount + 1;

        end
    end
    
    %Normalize the feature vector, for better result in different
    %brighthness and contrast.
    magd = norm(d);
    d = d/magd;
end