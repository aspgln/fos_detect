%This function convolves your image with the mexican hat template generated
%by mexhati. 
%
%
%
function convolved_image = mexconv(I, mexihat)

% figure;imshow(I)
% title('original')

norm = mat2gray(I);
% figure;imshow(norm)
% title('after mat2gray before conv')

HH = conv2(norm,mexihat,'same');
figure;imshow(HH);
title('after convolution')

II = mat2gray(HH);
figure;imshow(II);
title('after renormalizing after convolution')

convolved_image = HH;