function [Features] = new_compute_shape_features(Binary_image,patch_size,number)


% first check how many objects in this patch, and check if it is on the
% border
% 2 options to check # objects
[B,L,N,A] = bwboundaries(Binary_image,'noholes');
% return B: a cell array of boundary pixel locations
%        L: a label matrix where objects and holes are labeled
%        N: # of objects
%        A: an adjacency matrix
[L,N] = bwlabel(Binary_image);

% first check if candidate is on the border, if not, imclearborder
for i = (1:N)
    if ~(B{i,1} consists 0 or 81 )  % need to check B implementation
        Binary_image = imclearborder(Binary_image);
    end
end

% second check if more than one object
%n cells B{i,1}
if (N > 1)
    Properties = regionprops(Binary_image, 'Centroid', 'PixelIDxList'); 
    for i = 1:N
        if (Properties(i).Centroid(1) > max(B{i,1}(1,:)) || ... 
            Properties(i).Centroid(1) < min(B{i,1}(2,:)) || ...
            (Properties(i).Centroid(2) > max(B{i,1}(1,:)) || ...
            Properties(i).Centroid(2) < min(B{i,1}(2,:))))
            Binary_image(Properties(i).PixelIdxList) = 0;% get rid of other candidates in the region
        end
    end
          
end

% then do regionprops

