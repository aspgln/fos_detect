function Binary_mask = mexican_hat(I, Size, Sigma, Std)



I_bw = mat2gray(I);

%pad image with zeros
I_pad = padarray(I_bw, [70 70],'replicate');

%Creating mexican hat template and convolving with image
mex_hat = mexhati(Size, Sigma);
I_hat = mexconv(I_pad,mex_hat);

%Create a threshold. Take the mean of the of the whole image and find the
%standard deviation

%converting image matrix to a vector
sz_image = size(I_hat);
img_vector = reshape(I_hat, [1 sz_image(1)*sz_image(2)]);
avg_image = mean(img_vector);
std_image = std(img_vector);
Binary_mask = I_hat > (avg_image + Std * std_image);

%removing padding of image
Binary_mask(1:70,:)=[];
Binary_mask(end-69:end,:)= [];
Binary_mask(:,1:70)=[];
Binary_mask(:,end-69:end)=[];
