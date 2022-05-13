% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1
%
% Function extract features of keypoints based on descriptor
% @args:
% I        -> the input image
% xcoords  -> the x coordinates of the keypoints
% ycoords  -> the y coordinates of the keypoints
% @outputs:
% features -> an NxK matrix, where N: number of keypoints, K: descriptor
%             vector size
% varargin -> pass 'upgrade' if the upgraded local descriptor is to be used
function features = myExtractFeatures(I, xcoords, ycoords, varargin) 

    % Set minimum and maximum radius and radius step to get info about
    rhom = 1;
    rhoM = 20;
    rhostep = 1;
    % Along with how many points to get per circle
    N = 32;
    
    %For rhom=1, rhoM=20, rhostep=1, N=32 good results have been achieved
    
    %Turn the image to double
    I=im2double(I);
    
    %Get an array of all radius
    rhos = rhom:rhostep:rhoM;
    
    %k is the lenght of the feature vector (1 element per radius)
    k = length(rhos);
    
    %Number of keypoints
    numpoints = length(xcoords);
    
    %Matrix that holds the features
    features = zeros(numpoints, k);

    descriptor = @myLocalDescriptor;
    
    if nargin > 3
        useUpgrade = varargin{1};
        if strcmp(useUpgrade, 'upgrade')
            descriptor = @myLocalDescriptorUpgrade;
            %Filter the image with a gaussian filter for better results
            I = imgaussfilt(I,1);
        end
    end
    
    
    %Iterate through all keypoints
    for i=1:numpoints
        
        %Get the keypoint's coordinates
        x = xcoords(i);
        y = ycoords(i);
        
        p = [x,y];

        %Find its descriptor
        f = descriptor(I,p,rhom ,rhoM ,rhostep ,N);
        
        %If a non empty descriptor is found, append it to the matrix.
        if ~isempty(f)
            features(i,:) = f;
        end
    end
end