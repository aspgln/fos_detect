
%This function standardizes the grayscale image along wtih reorienting the
%object so that the major axis is vertical. Patch and Gray refer to the
%gray scale image and B_W and Segment refer to the biarized image.

function [Gray, B_W] = process_reorient(Patch,Segment)

%Parameters


%Normalize the Patch.


Patch_double = im2double(Patch);
N_Patch_Dbl = (Patch_double - mean(Patch_double(:)))/std(Patch_double(:));
N_Patch_int = im2uint8(N_Patch_Dbl);

% PatchSeg = N_Patch_int;
% PatchSeg(Segment == 0) = 0; %Any points in the Patch that doesnt belong to 
%                             %segment of interest is 0 

[H, Theta, Rho] = hough(Segment);
Peak = houghpeaks(H);
angle = Theta(Peak(:,2)); %1 is peak rho; 2 is peak theta.

Gray = imrotate(N_Patch_int, angle,'crop');
B_W = imrotate(Segment, angle, 'crop');
end



% figure;imshow(imNint)
% figure;imshow(Gray_patch(32).image)