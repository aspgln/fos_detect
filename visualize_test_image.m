function [] = visualize_test_image (image_path, predict_label)


I = imread(image_path);
I_bw = mat2gray(I);

mask = mexican_hat(I,80,4,3);

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
v = [];
for i = 1:num_of_candidates
    if ( predict_label(i) == 0)
        v = cat(1,v, {i,'-'});
    end
    if (predict_label(i) == 1)
        v = cat(1,v, {i,'+'});
    end
    
end

figure;
imshow(I_bw);
hold on;
for i = 1:length(v)

    if v{i,2} == '+'
        x = candidate_centroid(v{i,1},1);
        y = candidate_centroid(v{i,1},2);
        plot(x,y, 'g*', 'Linewidth',1)
        text(x,y,['  ' num2str(v{i,1}) '+'],'color','g');
    end
 
end


% confusion matrix
