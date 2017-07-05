function [mislabel] = check_mislabeled (image_path, Label_vector, predict_label)


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
% figure;imshow(L)


[L2, num_of_candidates] = bwlabel(L);
% figure;imshow(L); title('L2')
Candidate_properties = regionprops(L2, 'Centroid', 'PixelIDxList'); 
%%
mislabel = [];
num_of_mislabel = 0;
for i = 1:num_of_candidates
    if (Label_vector(i) == 1 && predict_label(i) == 0)
        mislabel = cat(1,mislabel, {i,'false negative'});
    end
    if (Label_vector(i) == 0 && predict_label(i) == 1)
        mislabel = cat(1,mislabel, {i,'false positive'});
    end
    if (Label_vector(i) == 1 && predict_label(i) == 1)
        mislabel = cat(1,mislabel, {i,'ttrue positive'});
    end
end

figure;
imshow(I_bw);
hold on;
for i = 1:length(mislabel)
    
    if mislabel{i,2} == 'false negative'
        x = candidate_centroid(mislabel{i,1},1);
        y = candidate_centroid(mislabel{i,1},2);
        plot(x,y, 'r*', 'Linewidth', 1)
        text(x,y, ['  ' num2str(mislabel{i,1}) ' false -'],'color','r');
    end
   
    if mislabel{i,2} == 'false positive'
        x = candidate_centroid(mislabel{i,1},1);
        y = candidate_centroid(mislabel{i,1},2);
        plot(x,y, 'c*', 'Linewidth',1)
        text(x,y,['  ' num2str(mislabel{i,1}) ' false +'],'color','c');
    end
    
    if mislabel{i,2} == 'ttrue positive'
        x = candidate_centroid(mislabel{i,1},1);
        y = candidate_centroid(mislabel{i,1},2);
        plot(x,y, 'g*' )
        text(x,y,'  true +','color','g');
    end
end


% confusion matrix
