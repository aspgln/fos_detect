clear all
close all
clc

%This script will apply the mexican hat function to images to preliminarily
%pick out candidate areas that are fos positive. 

%Choosing image file 
[filename,pathname,filterindex] = uigetfile('*.tif', 'Select image file');
file_cat = strcat(pathname,filename);
I = imread(file_cat);
I_bw = mat2gray(I);

%pad image with zeros
I_pad = padarray(I_bw, [70 70],'replicate');

%Creating mexican hat template and convolving with image
mex_hat = mexhati(60,8);
I_hat = mexconv(I_pad,mex_hat);

%Create a threshold. Take the mean of the of the whole image and find the
%standard deviation

%converting image matrix to a vector
sz_image = size(I_hat);
img_vector = reshape(I_hat, [1 sz_image(1)*sz_image(2)]);
avg_image = mean(img_vector);
std_image = std(img_vector);
mask = I_hat > (avg_image + 3*std_image);
 figure;imshow(mask)
 title('mask after thresholding')

%removing padding of image
mask(1:70,:)=[];mask(end-70:end,:)= [];mask(:,1:70)=[];mask(:,end-70:end)=[];
figure;imshow(mask)

%Filtering out candidate targets that don't meet Area criterion and then
%plotting the candidate points that are left and displaying them over the
%original image. 
[L,n] = bwlabel(mask);
Candidate_properties = regionprops(L,'Area', 'PixelIdxList','Eccentricity', 'Centroid');

candidate_centroid = [];
for i = 1:n
     if Candidate_properties(i).Area < 70 ||  Candidate_properties(i).Area > 800
        L(Candidate_properties(i).PixelIdxList) = 0;
    else 
        candidate_centroid = [candidate_centroid; Candidate_properties(i).Centroid];
    end 
end
figure;imshow(L)

figure; 
imshow(I_bw)

figure; 
imshow(I_bw)
hold on
plot(candidate_centroid(:,1), candidate_centroid(:,2), 'o')













