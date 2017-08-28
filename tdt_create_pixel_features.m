function [Labels, BW_patch, Gray1_patch, Gray2_patch, Feature_vector] = tdt_create_pixel_features(image_path, tag_path, target)
%Gray 1 is using original I_bw
%Gray 2 is after mexican_hat

disp(image_path);
disp(tag_path);
%%  

I = imread(image_path);
I_bw = mat2gray(I);
I_gray_1 = I_bw;   
%%
% %histogram equilization
I_equalized = adapthisteq(I_bw,'ClipLimit',.1);
% figure;
% imshow(I_equalized);
% title('adaptive histogram equalization')

[mask, I_gray_2] = mexican_hat(I,80,4,2.5);

%%
[L,n] = bwlabel(mask);
Candidate_properties = regionprops(L,'Area', 'PixelIdxList', 'Centroid');

candidate_centroid = [];
for i = 1:n
     if Candidate_properties(i).Area < 100        ||  Candidate_properties(i).Area > 1000
        L(Candidate_properties(i).PixelIdxList) = 0;
    else 
        candidate_centroid = [candidate_centroid; Candidate_properties(i).Centroid];
    end 
end
%  figure;imshow(L)


[L2, num_of_candidates] = bwlabel(L);
% figure;imshow(L); title('L2')
Candidate_properties = regionprops(L2, 'Centroid', 'PixelIDxList'); 


%% tag

[num,txt,raw] = xlsread(tag_path);

% target = 'cfos';
import_tags = [];
for i = 1:size(raw,1)
    if (contains(raw(i,2), target) || contains(raw(i,2), 'colabel'))
        import_tags = [import_tags;horzcat(num(i-1,1), num(i-1,3:4))];
    end
end

% import tags, pair tags with candidates
[num_of_positive_signals,positive_signals] = match_tags(import_tags, Candidate_properties);
pos = positive_signals(:,1);

% set label of positive signals to 1
% num_of_candiates is number of patches/signals in one image
Labels = zeros(num_of_candidates, 1);
Labels(pos) = 1;


%%tags-read, centroid-green
%  figure;
%   imshow(I_gray_2);
%  hold on;
%  plot(import_tags(:,2), import_tags(:,3),'r*');  % manually tag red
%  %     
%  hold on
%  plot(candidate_centroid(:,1), candidate_centroid(:,2), 'go')

%% create BW patch around each candidate
patch_size = 60;
for i=1:num_of_candidates
    % filter
    % set pixelidxlist of target candidate to 1, all the other to 0
    Base = zeros(size(L2));
    Base(Candidate_properties(i).PixelIdxList) = 1; 
    x = Candidate_properties(i).Centroid(1);
    y = Candidate_properties(i).Centroid(2);
    BW_patch(i).image = create_patch(Base,x,y,patch_size);
    Gray1_patch(i).image = create_patch(I_gray_1, x,y,patch_size);
    Gray2_patch(i).image = create_patch(I_bw, x,y,patch_size);

    
    %Normalizing the patches and reorienting so that it is vertical
%     [Gray_Patch_normal(i).image, BW_patch_reorient(i).image] = process_reorient(Gray_patch(i).image, BW_patch(i).image);
    
    
end
%      figure;imshow(Gray2_patch(3).image);



% % plot patches
% figure;colormap(gray);
% for i = 1:225
%     subplot(15,15,i)
%     patch = reshape(BW_patch(i).image, [41,41]);
%     imagesc(patch)
% end
%   
% figure;colormap(gray);
% for i = 1:100
%     subplot(10,10,i)
%     patch = reshape(Gray_patch(i).image, [41,41]);
%     imagesc(patch)
% % %     title(num2str(tr(i, 1)))                    % show the label
% 
% end

%% reshape patches 

% output for CNN
% BW_px_vector
% Gray2_px_vector


% need to avoid magic number!!!!

% BW_px_vector = [];
% Gray1_px_vector = [];
% Gray2_px_vector = [];
% 
% for i = 1:num_of_candidates
%     BW_px = reshape(BW_patch(i).image, [1,1681]);
%     Gray1_px = reshape(Gray1_patch(i).image, [1,1681]);
%     Gray2_px = reshape(Gray2_patch(i).image, [1,1681]);
% 
%     BW_px_vector = [BW_px_vector;  BW_px];
%     Gray1_px_vector = [Gray1_px_vector;  Gray1_px];
%     Gray2_px_vector = [Gray2_px_vector;  Gray2_px];
% 
% end




