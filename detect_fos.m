clear all
close all
clc

%This script will apply the mexican hat function to images to preliminarily
%pick out candidate areas that are fos positive. 

%Choosing image file 
[filename,pathname,filterindex] = uigetfile('*.tif', 'Select image file');
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
     if Candidate_properties(i).Area < 25                ||  Candidate_properties(i).Area > 200
        L(Candidate_properties(i).PixelIdxList) = 0;
    else 
        candidate_centroid = [candidate_centroid; Candidate_properties(i).Centroid];
    end 
end
% figure;imshow(L)



%%
% import tag
% raw both numeric and text data in cell array
% [filename,pathname,filterindex] = uigetfile('*.xlsx', 'Select tag file');
% file_cat = strcat(pathname,filename);

file_cat = '/Users/qingdai/Desktop/fos_detection/pictures/tagged data of #20 E3 LDH.xlsx';
% 
% [num_of_positive_signals,positive_signals_index] = 
% [num,txt,raw] = xlsread(file_cat);
% 
% 
% import_tags = [];
% for i = 1:size(raw,1)
%     if (contains(raw(i,2), 'Cfos') || contains(raw(i,2), 'Colabel'))
%         import_tags = [import_tags;horzcat(num(i-1,1), num(i-1,3:4))];
%     end
% end
% 
% 
% %compared centroid and tags in two different colors
% num_of_positive_signals = length(import_tags);
% 
% 
% 
% positive_signals_index = [];
% 
% % pair tag and signals with minimun euclidean norm
% 
% 
% 
% all_norms = zeros(num_of_positive_signals, 1);
% 
% 
% for i = 1:length(import_tags)
%     eu_norm = zeros(length(candidate_centroid),1);
% 
%     for j = 1:length(candidate_centroid)
%         eu_norm(j) = norm(import_tags(i,2:3) -candidate_centroid(j,:));
%     end
%     
%     [min_norm,index] = min(eu_norm);
%     all_norms(i) =  min_norm;
%     positive_signals_index = cat(1,positive_signals_index, index);  %index in Candidate_centroid
% end


[num_of_positive_signals,positive_signals_index] = tag_import(file_cat, candidate_centroid);


%%tags-read, centroid-green
figure;
imshow(L);
hold on;
plot(import_tags(:,2), import_tags(:,3),'r*');  % manually tag red
    
hold on
plot(candidate_centroid(:,1), candidate_centroid(:,2), 'go')


%%

%Recomputing the candidate patches after filtering out for size previously 
[L2, n] = bwlabel(L);
figure;imshow(L); title('L2')

Candidate_properties = regionprops(L2, 'Centroid', 'PixelIDxList'); 


patch_size = 80;

for i=18

    % filter
    Base = zeros(size(L2));
    Base(Candidate_properties(i).PixelIdxList) = 1; 
    
    x = Candidate_properties(i).Centroid(1);
    y = Candidate_properties(i).Centroid(2);
    BW_patch.image = create_patch(Base,x,y,patch_size);
%     
%     
    
    figure;imshow(BW_patch.image);
%     
    
    

end
%%

L_Cfos = L;
% L_Tdt = L;

