clear all
close all
clc

%%
counter = 0;
answer = input('more images? y or n', 's');

cfos_feature_vector = [];
cfos_label_vector = [];
tdt_feature_vector = [];
tdt_label_vector = [];

while answer == y
    counter = counter + 1;
    target = ['cfos', 'tdt'];
    
    [filename,pathname] = uigetfile('../images/*.tif', 'Select cfos image file');
    cfos_image_path = [pathname, filename];
    
    [filename,pathname] = uigetfile('../images/*.tif', 'Select tdt image file');
    tdt_image_path = [pathname, filename];
    
    [filename,pathname] = uigetfile('../images/*.xlsx', 'Select tag file');
    tag_path = [pathname, filename];
    
    [cfos_features, cfos_labels] = extract_feature(cfos_image_path, tag_path, 'cfos');
    
    cfos_feature_vector = [cfos_feature_vector; cfos_features];
    cfos_label_vector = [cfos_label_vector; cfos_labels];

    [tdt_features, tdt_labels] = extract_feature(tdt_image_path, tag_path, 'tdt');
    tdt_feature_vector = [tdt_feature_vector; tdt_features];
    tdt_label_vector = [tdt_label_vector; tdt_labels];

end


%% train model

% train_data = Feature_vector;
% train_label = Label_vector;

% -s svm_type 
% -t kernel_type 
% -b probability_estimates 0 for SVC
% -c cost parameter
% -g gamma

% model = svmtrain(train_label, train_data, '-c 1 -b 1 -t 0 -s 0');
cfos_model = svmtrain(cfos_label_vector, cfos_feature_vector, '-c 5 -b 0  -t 0 -s 0');
cfos_model_linear = svmtrain(cfos_label_vector, cfos_feature_vector, '-t 0');
cfos_model_polynomial = svmtrain(cfos_label_vector, cfos_feature_vector, '-t 1');
cfos_model_RBF = svmtrain(cfos_label_vector, cfos_feature_vector, '-t 2');
cfos_model_sigmoid = svmtrain(cfos_label_vector, cfos_feature_vector, '-t 3');

tdt_model = svmtrain(tdt_label_vector, tdt_feature_vector, '-c 5 -b 0  -t 0 -s 0');
tdt_model_linear = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 0');
tdt_model_polynomial = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 1');
tdt_model_RBF = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 2');
tdt_model_sigmoid = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 3');


%% 
[filename,pathname,filterindex] = uigetfile('../images/*.tif', 'Select image file');
image_path = [pathname, filename];

[filename,pathname,filterindex] = uigetfile('../images/*.xlsx', 'Select tag file');
tag_path = [pathname, filename];

[Feature_vector, Label_vector, num_of_candidates] = extract_feature(image_path, tag_path, target);



%% test model
% test_fn = '../data/leu.test';
% [test_label, test_data] = libsvmread(test_fn);

test_data = Feature_vector;
test_label = Label_vector;

% @predictd_label: is a vector of predicted labels.
% @accuracy, is a vector including accuracy (for classification), mean
%   squared error, and squared correlation coefficient (for regression).
% @matrix, containing decision values ([-1,0] -> -1, [0,1] -> 1)

[predict_label, accuracy, dec_valuesL] = ...
       svmpredict(test_label, test_data, model);

[predict_label_L, accuracy_L, dec_values_L] = ...
       svmpredict(test_label, test_data, model_linear);
   
[predict_label_P, accuracy_P, dec_values_P] = ...
       svmpredict(test_label, test_data, model_polynomial);
     
[predict_label_RBF, accuracy_RBF, dec_values_RBF] = ...
       svmpredict(test_label, test_data, model_RBF); 
   
[predict_label_S, accuracy_S, dec_values_S] = ...
       svmpredict(test_label, test_data, model_sigmoid); 
   
  [predicted_label, accuracy, prob_estimates] = ... 
      svmpredict(test_label, test_data, model, '-b 1');
%  





%% analyze
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
figure;imshow(L); title('L2')
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
        text(x,y,'  false -','color','r');
    end
   
    if mislabel{i,2} == 'false positive'
        x = candidate_centroid(mislabel{i,1},1);
        y = candidate_centroid(mislabel{i,1},2);
        plot(x,y, 'c*', 'Linewidth',1)
        text(x,y,'  false +','color','c');
    end
    
    if mislabel{i,2} == 'ttrue positive'
        x = candidate_centroid(mislabel{i,1},1);
        y = candidate_centroid(mislabel{i,1},2);
        plot(x,y, 'g*' )
        text(x,y,'  true +','color','g');
    end
end


% confusion matrix


