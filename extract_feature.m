function [Feature_vector, num_of_candidates, candidate_centroid] = extract_feature(image_path)
% image_path = cfos_test_image_path;
I = imread(image_path);
I_bw = mat2gray(I);

mask = mexican_hat(I,80,4,2.5);
% figure;imshow(mask);title('after mexican hat');

% % file_cat = '/Users/qingdai/Desktop/fos_detection/pictures/#20_E3_LDH_tdt_10x_500ms.tif';
% I2 = imread(file_cat);
% I_bw2 = mat2gray(I2);

%%
% %histogram equilization
I_equalized = adapthisteq(I_bw,'ClipLimit',.2);
% figure;
% imshow(I_equalized);
% title('adaptive histogram equalization')




%%
%Filtering out candidate targets that don't meet Area criterion and then
%plotting the candidate points that are left and displaying them over the
%original image. 
[L,n] = bwlabel(mask);
Candidate_properties = regionprops(L,'Area', 'PixelIdxList', 'Centroid');

candidate_centroid = [];
for i = 1:n
     if Candidate_properties(i).Area < 25               ||  Candidate_properties(i).Area > 400
        L(Candidate_properties(i).PixelIdxList) = 0;
    else 
        candidate_centroid = [candidate_centroid; Candidate_properties(i).Centroid];
    end 
end
% figure;imshow(L)


[L2, num_of_candidates] = bwlabel(L);
% figure;imshow(L); title('L2')
Candidate_properties = regionprops(L2, 'Centroid', 'PixelIDxList'); 




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
%     gg = i
%    figure;imshow(BW_patch(160).image);
    Shape_features(i,:) = compute_shape_features_revised(BW_patch(i).image,patch_size);
   
end
% Shape_features = compute_shape_features(BW_patch_reorient(1).image,patch_size, number);

%%

%Texture features

num_histogram_bins = 16;

% determine the size of Texture_vector
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
Feature_vector = [Shape_features, Texture_features];

    
    