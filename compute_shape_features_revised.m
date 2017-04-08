%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Calculates shape features using only the binary image which   
%     should only contain your segment of interest. (no noise)
%
%
%              Bau Pham 07/2016
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The output are the set of 10 shape features that include solidity, perimeter,
%orientation, equivDiameter, Area, Eccentricity, Convex Area, Major and
%Minor Axis length, Extent.

function [Features] = compute_shape_features_revised(Binary_image, patch_size)




% B = bwperim(Binary_image,4);
Props = regionprops(Binary_image, 'Solidity', 'Perimeter',...
                    'Orientation','EquivDiameter','Area', 'Eccentricity',...
                    'ConvexArea', 'MajorAxisLength', 'MinorAxisLength',...
                    'Extent');
                
% 
% %Find the biggest area from the region props function. Your target should
% %have the largest area. Don't need the area of the noise or background
% if length(Props) ~= 1
%     Areas = regionprops(Binary_image, 'Area');
%     Areas_array = struct2array(Areas);
%     [Sorted_Areas, Sorted_Index] = sort(Areas_array,'descend');
%     Props = Props(Sorted_Index(1));
% end
% % 
% % [Sorted_Area, Sorted_Index] = sort(Props.Area);
% % Area = Sorted_Area(1);%take the largest area


%Creating normalized vector of Features
Features = [];

Features = [Features, Props.Solidity,... %ratio no need to normalize
            Props.Perimeter/(patch_size*4),...%normalize perimeter to perimeter of window
            (Props.Orientation + 90)/180,... %angle make it between 0-180 instead of -90-90
            Props.EquivDiameter/(sqrt(patch_size^2/pi)*2),... %Normalize diamter with equivalent circle with area of the patch
            Props.Area/(patch_size^2),... %normalize with area of the patch
            Props.Eccentricity,... ratio no need to normalize
            Props.ConvexArea/(patch_size^2),... %normalize with area of the patch
            Props.MajorAxisLength/(patch_size*sqrt(2)),... %normalize with max diagonal of the patch
            Props.MinorAxisLength/(patch_size*sqrt(2)),... %normalize with max diagonal of the patch
            Props.Extent]; %ratio no need to normalize
end
                
                



