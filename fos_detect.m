%%
clear all
close all
clc

%Declare Variables and find images
%--------------------------------------------------------------------------

min_fos_size = input('What is the minimum synapse size?');
max_fos_size = input('What is the maximum synapse size?');
patch_size = 60;
number = 1; %number of objects that comprise your target
num_histogram_bins = 16;
[filename,pathname,filterindex] = uigetfile('*.tif', 'Select image file');
file_cat = strcat(pathname,filename);
I = imread(file_cat);
I_bw = I(:,:,1);
I_bw = uint8(I_bw);


%%
figure
imshow(I_bw);
title('original bw');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%             IMAGE PROCESSING                       %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%histogram equilization
I_equalized = adapthisteq(I_bw,'ClipLimit',1);
figure
imshow(I_equalized);
title('adaptive histogram equalization')

%%
%Histogram adjustment.
J = imadjust(I_equalized,[0.3; 1],[0; 1]);
figure; imshow(J);title('adjusted adaptive')

%%
%Creating Binary  Image and processing it
%------------------------------------------------------------------------

BW = im2bw(J,graythresh(J));   %Thresholding to create binary mask
  figure;imshow(BW);
%  title('binarized adjusted')
%%
%Detecting groups of pixels whose gradient is higher than surroundings
U = imextendedmax(I_equalized,30);
figure;imshow(U);
% title('IMextendedmax');

%%
U = imfill(U,'holes');       %Filling in holes
%  figure;imshow(U);
% title('Holes filled')

%%
se = strel('disk',1);
% BW3 = imopen(BW2,se);
%  figure;imshow(BW3);
% % title('after decimation');

%%
% BW4 = imclose(BW3,se);
%  figure;imshow(BW4);
% % title('After dilation')

%%
%Finding candidate segments
%--------------------------------------------------------------------------

[L,n] = bwlabel(U);
Candidate_properties = regionprops(L,'Area', 'Perimeter', 'PixelIdxList');

for i = 1:n
    if Candidate_properties(i).Area < 100 || Candidate_properties(i).Area > 1000
        L(Candidate_properties(i).PixelIdxList) = 0;
    end 
end

figure;imshow(L);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  Feature Extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Recomputing the candidate patches after filtering out for size previously 
[L2, n] = bwlabel(L);
Region = regionprops(L2, 'Centroid', 'PixelIDxList'); 
%%
%Creating window patches for candidates
for i = 1:n
    
    x = Region(i).Centroid(1);
    y = Region(i).Centroid(2);
    BW_patch(i).image = create_patch(L2,x,y,patch_size)/i;
    Gray_patch(i).image = create_patch(I_equalized, x,y,patch_size);
    
    %figure; imshow(BW_patch(i).image)
    %figure; imshow(Gray_patch(i).image) 
    
    %Normalizing the patches and reorienting so that it is vertical
    [Gray_Patch_normal(i).image, BW_patch_reorient(i).image] = process_reorient(Gray_patch(i).image, BW_patch(i).image);
    %figure; imshow(BW_patch_reorient(i).image)
    %figure; imshow(Gray_patch_normal(i).image) 
end

%%
%Start extracting features
%--------------------------------------------------------------------------

%Shape features


% for i = 1:n
%     figure; 
%     imshow(BW_patch_reorient(i).image);
% end


Shape_features = zeros(n,10);
for i = 1%:n
   gg = i
    Shape_features(i,:) = compute_shape_features(BW_patch_reorient(i).image,patch_size, number);
   
end
% Shape_features = compute_shape_features(BW_patch_reorient(32).image,patch_size, number);


%%

%Texture features
Texture_features = Compute_MR8(Gray_Patch_normal(1).image, num_histogram_bins);

[a,b] = size(Texture_features);
Texture_features = zeros(n, a*b);

for i = 1:n
    Texture_matrix = Compute_MR8(Gray_Patch_normal(i).image, num_histogram_bins);
    Texture_features(i,:) = reshape(Texture_matrix, [1,a*b]);
end

% Texture_features = Compute_MR8(Gray_Patch_normal(32).image, num_histogram_bins);



%%

%HoG features 
%5 parameters: int nb_bins, double cwidth, int block_size, int orient,  double clip_val

HoG_features = HoG(im2double(Gray_Patch_normal(1).image), [9,10,6,1,0.2]);
HoG_features = zeros(n,length(HoG_features));

for i = 1:n
    HoG_features(i,:) = HoG(im2double(Gray_Patch_normal(i).image), [9,10,6,1,0.2]);
end

%HoG_features = HoG(im2double(Gray_Patch_normal(5).image), [9,10,6,1,0.2]);

%%
%Putting together the feature vector
Feature_vector = horzcat(Shape_features, Texture_features, HoG_features);
num_of_features = size(Feature_vector, 2);

       
Feature_vector = horzcat(Feature_vector, zeros(n, 1));



















