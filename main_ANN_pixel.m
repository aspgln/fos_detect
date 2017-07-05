%%
[filename,pathname] = uigetfile('../images/new/test/*.tif', 'Select image file');
cfos_test_image_path = [pathname, filename]

% [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
% tdt_test_image_path = [pathname, filename];
%%  
I = imread(image_path);
I_bw = mat2gray(I);
    
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

%% create BW patch
patch_size = 80;
for i=1:num_of_candidates
    % filter
    % set pixelidxlist of target candidate to 1, all the other to 0
    Base = zeros(size(L2));
    Base(Candidate_properties(i).PixelIdxList) = 1; 
    x = Candidate_properties(i).Centroid(1);
    y = Candidate_properties(i).Centroid(2);
    BW_patch(i).image = create_patch(Base,x,y,patch_size);
    
    %Normalizing the patches and reorienting so that it is vertical

%     figure;imshow(BW_patch_reorient(297).image);
%     
   
end
    
%% tag
[filename,pathname] = uigetfile('../images/new/test/*.xlsx', 'Select tag file');
tag_path = [pathname, filename]
    
[num,txt,raw] = xlsread(tag_path);


import_tags = [];
for i = 1:size(raw,1)
    if (contains(raw(i,2), target) || contains(raw(i,2), 'colabel'))
        import_tags = [import_tags;horzcat(num(i-1,1), num(i-1,3:4))];
    end
end

% import tags, pair tags with candidates
[num_of_positive_signals,positive_signals] = match_tags(import_tags, Candidate_properties);

%%tags-read, centroid-green
figure;
imshow(I_bw);
hold on;
plot(import_tags(:,2), import_tags(:,3),'r*');  % manually tag red
    
hold on
plot(candidate_centroid(:,1), candidate_centroid(:,2), 'go')

    
%%