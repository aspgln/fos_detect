% This is a mexican hat function. This function will return a
% two-dimensional template of a mexican hat. Input size designates how big
% the template is in terms of pixels. Ex. size = 50 will return a mexican
% hat template that is 50 pixels by 50 pixels. Sigma is the standard
% deviation of the Gaussian function which also determins the width and
% size of the mexican hat function.
%
%

%Mexican hat function
function mexican_hat = mexhati(size,sigma)

[x,y] = meshgrid(0:1:size);
shift = size/2; 
a = 1;

mexhat = (a/(pi*sigma^2))*(1 - ((x-shift).^2+(y-shift).^2)/(2*sigma^2)).*exp(-(((x-shift).^2+(y-shift).^2))/(2*sigma^2));
% figure; surf(x,y,mexhat);
mexican_hat = mexhat;