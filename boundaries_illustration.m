Binary_image = BW_patch(2).image;
figure;imshow(Binary_image);
Binary_image = imclearborder(Binary_image);
figure;imshow(Binary_image);

% use bwboundaries
[B,L,N,A] = bwboundaries(Binary_image,'noholes');
figure;imshow(label2rgb(L,@jet,[0 0 0]))
hold on
for k = 1:length(B)
    boundary = B{k}
    plot(boundary(:,2), boundary(:,1),'g', 'LineWidth' , 2)
end

% use bwtraceboundaries
BB = bwtraceboundary(Binary_image, [B{2,1}(1,1), B{2,1}(1,2)], 'N');
hold on ;
plot(BB(:,2), BB(:,1), 'g', 'LineWidth', 2)

[a,b] = bwlabel(Binary_image);

figure;imshowpair(Binary_image, a, 'montage')
