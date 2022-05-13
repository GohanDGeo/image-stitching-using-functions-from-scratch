% Georgios Koutroumpis, AEM: 9668
% Digital Image Processing, ECE AUTH 2022
% Project 1
%
% Function that matches features between two feature matrices.
% This is a brute force matching method.
% @args:
% f1   -> features of the keypoints in image 1
% f2   -> features of the keypoints in image 2
% @outputs:
% idx1 -> indices of the matched points in image 1
% idx2 -> indices of the matched points in image 2

function [idx1, idx2] = myMatchFeatures(f1, f2)

    %Get number of keypoints in image 1 & 2
    n1 = size(f1,1);
    n2 = size(f2,1);
    
    %Initialize the matched points array as the maximum number of possible
    %matches
    idx1 = zeros(1, min([n1,n2]));
    idx2 = idx1;
    
    %The distances between a feature from image 1 and the features in image
    %2
    dis = zeros(1,n2);
    
    %The minimum distance from a feature 1 to a feature 2
    min_dis = zeros(1,n1);
    
    %The threshold used to detect inlier matches
    thresh = 0.6;
    
    %The total number of matches
    nmatch = 0;
    
    %Find the best match for a feature 1 with the features 2
    for i=1:n1
        for j=1:n2
            %Calculate the match metric as the eucledian distance between
            %the 2 features
            dis(j) = norm(f1(i,:)-f2(j,:));
        end
        %Sort the distances between the ith feature 1 and all feature 2 
        %vecotrs, and get the feature2 with the min distance to feature1
        [dis, min_idx] = sort(dis);
        min_dis(i) = dis(1);
        
        %If the smallest distance is smaller enough from the second
        %smallest distance, according to the threshold <thresh> this match
        %is an inlier, and is appended to the matches.
        if(dis(1) < thresh*dis(2))
            nmatch = nmatch + 1;
            idx1(nmatch) = i;
            idx2(nmatch) = min_idx(1);
        end
    end
    
    %Remove empty matches
    idx1 = idx1(1:nmatch);
    idx2 = idx2(1:nmatch);
    
    %For our purposes, we need 3 matches. If less than 3 matches are found,
    %print that not enough have been found, and all matches are returned.
    if nmatch < 3
        fprintf("Not enough matches found!\n");
    else
        %Get the distances of all matches
        val_dis = min_dis(idx1);
        
        %Sort the distances and finally only get the 3 best matches (the
        %ones with the smaller distance)
        [~, ind_dis] = sort(val_dis);
        
        idx1 = idx1(ind_dis(1:3));
        idx2 = idx2(ind_dis(1:3));
    end
    
    
end