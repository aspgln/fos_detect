% clear all
close all
clc

%This script will apply the mexican hat function to images to preliminarily
%pick out candidate areas that are fos positive. 

%Choosing image file 
[filename,pathname,filterindex] = uigetfile('../*.tif', 'Select image file');
file_cat = strcat(pathname,filename)
% file_cat = '/Users/qingdai/Desktop/fos_detection/pictures/#20_E3_LDH_cfos_10x_1800ms.tif'
% file_cat = '/Users/qingdai/Desktop/fos_detection/pictures/#20_E3_LDH_tdt_10x_500ms.tif';

I = imread(file_cat);
I_bw = mat2gray(I);

mask = mexican_hat(I,80,4,3);
figure;imshow(mask);title('after mexican hat');

% % file_cat = '/Users/qingdai/Desktop/fos_detection/pictures/#20_E3_LDH_tdt_10x_500ms.tif';
% I2 = imread(file_cat);
% I_bw2 = mat2gray(I2);

%%
%histogram equilization
I_equalized = adapthisteq(I_bw,'ClipLimit',.2);
figure;
imshow(I_equalized);
title('adaptive histogram equalization')




%%
%Filtering out candidate targets that don't meet Area criterion and then
%plotting the candidate points that are left and displaying them over the
%original image. 
[L,n] = bwlabel(mask);
Candidate_properties = regionprops(L,'Area', 'PixelIdxList', 'Centroid');

candidate_centroid = [];
for i = 1:n
     if Candidate_properties(i).Area < 25                ||  Candidate_properties(i).Area > 400
        L(Candidate_properties(i).PixelIdxList) = 0;
    else 
        candidate_centroid = [candidate_centroid; Candidate_properties(i).Centroid];
    end 
end
% figure;imshow(L)


[L2, num_of_candidates] = bwlabel(L);
figure;imshow(L); title('L2')
Candidate_properties = regionprops(L2, 'Centroid', 'PixelIDxList'); 


%%
% import tag
% raw both numeric and text data in cell array
[filename,pathname,filterindex] = uigetfile('../*.xlsx', 'Select tag file');
file_cat = strcat(pathname,filename);


% raw takes both numeric and text data in cell array


% file_cat = '/Users/qingdai/Desktop/fos_detection/pictures/tagged data of #20 E3 LDH.xlsx';
[num,txt,raw] = xlsread(file_cat);


import_tags = [];
for i = 1:size(raw,1)
    if (contains(raw(i,2), 'Cfos') || contains(raw(i,2), 'Colabel'))
        import_tags = [import_tags;horzcat(num(i-1,1), num(i-1,3:4))];
    end
end

% import tags, pair tags with candidates
[num_of_positive_signals,positive_signals] = match_tags(import_tags, Candidate_properties);

%%tags-read, centroid-green
figure;
imshow(L);
hold on;
plot(import_tags(:,2), import_tags(:,3),'r*');  % manually tag red
    
hold on
plot(candidate_centroid(:,1), candidate_centroid(:,2), 'go')


%%
%Recomputing the candidate patches after filtering out size

patch_size = 80;
for i=1:num_of_candidates
    % filter
    % set pixelidxlist of target candidate to 1, all the other to 0
    Base = zeros(size(L2));
    Base(Candidate_properties(i).PixelIdxList) = 1; 
    
    x = Candidate_properties(i).Centroid(1);
    y = Candidate_properties(i).Centroid(2);
    BW_patch(i).image = create_patch(Base,x,y,patch_size);
    Gray_patch(i).image = create_patch(I_equalized, x,y,patch_size);
    
    %Normalizing the patches and reorienting so that it is vertical
    [Gray_Patch_normal(i).image, BW_patch_reorient(i).image] = process_reorient(Gray_patch(i).image, BW_patch(i).image);


%     figure;imshow(BW_patch.image);
%     
    
    

end
%%
%Start extracting features
%--------------------------------------------------------------------------

%Shape features


Shape_features = zeros(num_of_candidates,10);
for i = 1:num_of_candidates
%    gg = i
%    figure;imshow(BW_patch(160).image);
    Shape_features(i,:) = compute_shape_features_revised(BW_patch_reorient(i).image,patch_size);
   
end
% Shape_features = compute_shape_features(BW_patch_reorient(1).image,patch_size, number);

%%

%Texture features

num_histogram_bins = 16;

Texture_features = Compute_MR8(Gray_Patch_normal(1).image, num_histogram_bins);

[a,b] = size(Texture_features);
Texture_features = zeros(num_of_candidates, a*b);

for i = 1:num_of_candidates
    Texture_matrix = Compute_MR8(Gray_Patch_normal(i).image, num_histogram_bins);
    Texture_features(i,:) = reshape(Texture_matrix, [1,a*b]);
end

% Texture_features = Compute_MR8(Gray_Patch_normal(1).image, num_histogram_bins);



%%

%HoG features 
%5 parameters: int nb_bins, double cwidth, int block_size, int orient,  double clip_val

HoG_features = HoG(im2double(Gray_Patch_normal(1).image), [9,10,6,1,0.2]);
HoG_features = zeros(num_of_candidates,length(HoG_features));

for i = 1:num_of_candidates
    HoG_features(i,:) = HoG(im2double(Gray_Patch_normal(i).image), [9,10,6,1,0.2]);
end

%HoG_features = HoG(im2double(Gray_Patch_normal(5).image), [9,10,6,1,0.2]);

%%
% putting together all features vectors
Feature_vector = horzcat(Shape_features, Texture_features, HoG_features);

Label_vector = zeros(num_of_candidates,1);

for i = 1:num_of_positive_signals
    Label_vector(positive_signals(i,1)) = 1;
end
    
    



