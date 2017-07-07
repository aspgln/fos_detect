%% 



counter = 0;
answer = 'y';

pixel_vector = [];
label_vector = [];

while answer == 'y'
    counter = counter + 1;
%     target = ['cfos', 'tdt'];
    
    [filename,pathname] = uigetfile('../images/new/train/*.tif', 'Select image file');
    train_image_path = [pathname, filename];

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];


    [filename,pathname] = uigetfile('../images/new/train/*.xlsx', 'Select tag file');
    tag_path = [pathname, filename]

    [pixels, labels] = create_pixel_features(train_image_path, tag_path, 'cfos');
    
    pixel_vector = [pixel_vector  pixels];
    label_vector = [label_vector  labels];
    
    answer = input('more training images? y or n : ', 's');

end
%%  
I = imread(cfos_train_image_path);
I_bw = mat2gray(I);
    
%%
% %histogram equilization
I_equalized = adapthisteq(I_bw,'ClipLimit',.2);
% figure;
% imshow(I_equalized);
% title('adaptive histogram equalization')


%%
mask = mexican_hat(I,80,4,2.5);
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
%  figure;imshow(L)


[L2, num_of_candidates] = bwlabel(L);
% figure;imshow(L); title('L2')
Candidate_properties = regionprops(L2, 'Centroid', 'PixelIDxList'); 


%% tag

    
[num,txt,raw] = xlsread(tag_path);

target = 'cfos';
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
Labels = size(num_of_candidates);
Labels(pos) = 1;


% %%tags-read, centroid-green
% figure;
% imshow(I_bw);
% hold on;
% plot(import_tags(:,2), import_tags(:,3),'r*');  % manually tag red
%     
% hold on
% plot(candidate_centroid(:,1), candidate_centroid(:,2), 'go')

%% create BW patch around each candidate
patch_size = 40;
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
%     [Gray_Patch_normal(i).image, BW_patch_reorient(i).image] = process_reorient(Gray_patch(i).image, BW_patch(i).image);
    
    
end
%      figure;imshow(Gray_patch(308).image);



% plot patches
figure
colormap(gray)
for i = 1:225
    subplot(15,15,i)
    patch = reshape(BW_patch(i).image, [41,41]);
    imagesc(patch)
end
  
figure
colormap(gray)
for i = 1:100
    subplot(10,10,i)
    patch = reshape(Gray_patch(i).image, [41,41]);
    imagesc(patch)
%     title(num2str(tr(i, 1)))                    % show the label

end

%% reshape patches into linear indices

% pixels, BW or Gray ??????

pixel_vector = []
for i = 1
    pixels = reshape(BW_patch(i).image, [1,1681]);
    pixel_vector = [pixel_vector; pixels];
end




    
%%