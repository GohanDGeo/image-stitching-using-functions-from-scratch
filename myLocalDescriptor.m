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

function d = myLocalDescriptor(I,p,rhom ,rhoM ,rhostep ,N)
   
    %Get the size of the image
    [rows, cols, ~] = size(I);
    
    %Create an array of all radius that will be used
    rhos = rhom:rhostep:rhoM;
    
    %Get the coordinates of the point (floor in case it was given in
    %decimal form)
    xp = floor(p(1));
    yp = floor(p(2));
    
    %Check that at the maximum radius, the pixel will not be out of bounds
    %(the pixel at max radius + 1 to make it easier to use interpolation)
    if xp + (rhoM) > cols | yp + (rhoM) > rows | xp - (rhoM) < 1 | yp - (rhoM) < 1
        d = [];
    else
        
        %Initialize the vector d, with a size of the number of radius to be
        %used
        d = zeros(1, length(rhos));
        dcount = 1;
        for r=rhos
            
            %Get the pixel facing up of the pixel p, at the current radius
            x = xp;
            y = yp - r;
            
            %Initialize an array that will hold each pixel's value in this
            %radius
            rhovec = zeros(1, N);
            rhoveccount = 0;
            
            %For each angle/pixel in the circle get the value of the pixel
            for n=1:N

                %Calculate the angle in the circle. This goes from 2pi/N to
                %2pi, for a total of N points in a circle
                angle = (2*pi/N) * n;
                
                %Rotate the pixel that is at radius r upwards from the
                %pixel p by <angle> radians
                tfMat = [cos(angle), sin(angle); -sin(angle) cos(angle)];
                
                %The rotation is done around the pixel of interest, that is
                %why we subtract its coordinates and then add them again.
                coords = [y-yp x-xp]*tfMat;
                xrot = round(coords(2)) + xp;
                yrot = round(coords(1)) + yp;
                
                %{
                tfMat = [cos(angle) sin(angle); -sin(angle) cos(angle)];
                rotP = tfMat*[x-xp;y-yp] + [xp;y];
                xrot = rotP(1);
                yrot = rotP(2);
                %}
                %rhoveccount = rhoveccount + 1;
                
                %Add the value of the pixel that is on the value to the
                %vector rhovec, which holds the values of all the pixels in
                %the circle
                rhovec(n) = bilinearInterpolation(I, [xrot, yrot]);

                
            end
            
            %Make the entry of the vector <d> for this specific radius, the
            %mean of the values of the pixels on the circle.
            d(dcount) = mean(rhovec);
            dcount = dcount + 1;

        end
    end
end