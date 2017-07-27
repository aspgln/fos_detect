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

function [Features] = compute_shape_features(Binary_image,patch_size,number)

%Clear everything touching the border so in theory the only thing that
%remains is your target at the center of the patch/window
Binary_image = imclearborder(Binary_image);

Props = regionprops(Binary_image, 'Solidity', 'Perimeter',...
                    'Orientation','EquivDiameter','Area', 'Eccentricity',...
                    'ConvexArea', 'MajorAxisLength', 'MinorAxisLength',...
                    'Extent');

%Find the biggest area from the region props function. Your target should
%have the largest area. Don't need the area of the noise or background


[Sorted_Area, Sorted_Index] = sort(Props.Area);
Area = Sorted_Area(1:number);


%Creating normalized vector of Features
Features = [];
for i = 1:number
    Features = [Features, Props(Sorted_Index(i)).Solidity,... %ratio no need to normalize
                Props(Sorted_Index(i)).Perimeter/(patch_size*4),...%normalize perimeter to perimeter of window
                (Props(Sorted_Index(i)).Orientation + 90)/180,... %angle make it between 0-180 instead of -90-90
                Props(Sorted_Index(i)).EquivDiameter/(sqrt(patch_size^2/pi)*2),... %Normalize diamter with equivalent circle with area of the patch
                Area(i)/(patch_size^2),... %normalize with area of the patch
                Props(Sorted_Index(i)).Eccentricity,... ratio no need to normalize
                Props(Sorted_Index(i)).ConvexArea/(patch_size^2),... %normalize with area of the patch
                Props(Sorted_Index(i)).MajorAxisLength/(patch_size*sqrt(2)),... %normalize with max diagonal of the patch
                Props(Sorted_Index(i)).MinorAxisLength/(patch_size*sqrt(2)),... %normalize with max diagonal of the patch
                Props(Sorted_Index(i)).Extent]; %ratio no need to normalize
end
end
                
                



