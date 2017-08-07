clear all
close all
clc

%% extract features
counter = 0;
answer = 'y';

cfos_feature_vector = [];
cfos_label_vector = [];
tdt_feature_vector = [];
tdt_label_vector = [];

while answer == 'y'
    counter = counter + 1;
%     target = ['cfos', 'tdt'];
    
    [filename,pathname] = uigetfile('../images/new/untitled folder/*.tif', 'Select cfos image file');
    cfos_image_path = [pathname, filename];
    disp(filename);
    
%     [filename,pathname] = uigetfile('../images/*.tif', 'Select tdt image file');
%     tdt_image_path = [pathname, filename];
    
    [filename,pathname] = uigetfile('../images/new/untitled folder/*.xlsx', 'Select tag file');
    tag_path = [pathname, filename];
    disp(filename);

    
    [cfos_features, cfos_labels] = extract_feature_and_import_tags(cfos_image_path, tag_path, 'cfos');
    
    cfos_feature_vector = [cfos_feature_vector; cfos_features];
    cfos_label_vector = [cfos_label_vector; cfos_labels];

%     [tdt_features, tdt_labels] = extract_feature(tdt_image_path, tag_path, 'tdt');
%     tdt_feature_vector = [tdt_feature_vector; tdt_features];
%     tdt_label_vector = [tdt_label_vector; tdt_labels];
    
    answer = input('more training images? y or n : ', 's');

end

%% set default

BW_patch_vector = [];
Gray1_patch_vector = [];
Gray2_patch_vector = [];

label_vector = [];
 

%% load images and extract patches

% select multiple image and tag files
% [filename,pathname] = uigetfile('../images/new/DH/data/cfos/*.tif', ...
%     'Select image file', 'MultiSelect', 'on' );
[filename,pathname] = uigetfile('../data/DH/cfos/*.tif', ...
   'Select image file', 'MultiSelect', 'on' );
% store file paths in a vector
cfos_image_path_vector = strcat(pathname, filename(:)); 


[filename,pathname] = uigetfile('../data/DH/tag/*.xlsx', ...
    'Select image file', 'MultiSelect' , 'on');
tag_path_vector = strcat(pathname, filename(:));


% extract patches from each image, extract labels
l = length(filename);
tic
for i = 1: l
    % track time
    remain_time = (toc / i) * (l-i);
    
    s = sprintf(' %d / %d \n time used: %.2f \n time remains %.2f \n', i,l, toc, remain_time);    fprintf(s);   
    fprintf(s);  
    
    % extract patches from each image
    [ labels, BW_patch, ~, Gray2_patch]...                       
        = create_pixel_features(cfos_image_path_vector{i}, tag_path_vector{i}, 'cfos');

    BW_patch_vector = [BW_patch_vector   BW_patch];
    Gray2_patch_vector = [Gray2_patch_vector   Gray2_patch];         
    label_vector = [label_vector;  labels];      

end


 %% create data structure

% store all patches and corresponding in imageData 
imageData = struct('BW', BW_patch_vector, 'Gray', Gray2_patch_vector, ...
    'label', label_vector);  

%% extract features from patches
% shape features

patch_size = 40;

n = length(imageData.BW);

Shape_features = zeros(n,10);

for i = 1:n
    Shape_features(i,:) = compute_shape_features_revised(BW_patch_vector(i).image,patch_size);
   if mod(i,1000) == 0
        disp(i);
    end
end

% texture features

num_histogram_bins = 16;

% determine the size of Texture_vector
Texture_features = Compute_MR8(Gray2_patch_vector(1).image, num_histogram_bins);



[a,b] = size(Texture_features);
Texture_features = zeros(n, a*b);

for i = 1:n
    Texture_matrix = Compute_MR8(Gray2_patch_vector(i).image, num_histogram_bins);
    Texture_features(i,:) = reshape(Texture_matrix, [1,a*b]);
    if mod(i,1000) == 0
        disp(i);
    end
end

% Texture_features = Compute_MR8(Gray_Patch_normal(1).image, num_histogram_bins);


cfos_feature_vector = [Shape_features, Texture_features];


%% 
featureData = struct('Features', cfos_feature_vector, 'Label', label_vector);  

m = length(BW_patch_vector); 

% find the indices of all positive signals
positive_index = find(label_vector);

% find the indices of all negative signals
negative_index = setdiff(1:m, positive_index);


% randomly choose subsamples to balance data
% posInd = randsample(positive_index, 2500);
% negInd = randsample(negative_index, 2500);
negInd = randsample(negative_index, length(positive_index));


% combine and shuffle subsample
% total_index = [posInd; negInd'];
total_index = [positive_index; negInd'];

total_index = total_index(randperm(length(total_index)));

%% set cross validatin

% set k-fold validation
k = 5;
cv = cvpartition(total_index, 'kfold', k);
% cv = cvpartition(subtotal_index, 'kfold', k);

% % divide into three subsets with random indices      
% [trainInd,testInd] = dividerand(Q,80,20); 



%% learn
result = zeros(6,k);
tic

for i = 1:k
    % divide into two subsets by indices
    trainInd = total_index(training(cv,i));
    testInd  = total_index(test(cv,i));
    
    
    trainData = struct('Features', cfos_feature_vector(trainInd(1:end)), ...
        'Label', cfos_feature_vector(trainInd(1:end)));                                   

    testData = struct('Features', cfos_feature_vector(testInd(1:end)), ...
        'Label', cfos_feature_vector(testInd(1:end)));        
    
    cfos_model = svmtrain(trainData.Label, trainData.Features, '-c 15 -b 0 -t 0 -s 0');% 267/280
%     cfos_model_linear = svmtrain(trainData.Label, trainData.Features, ' -b 1 -t 0 -s 0');% 267/280

    
    [cfos_predict_label, accuracy, dec_values] = ...
       svmpredict(testData.Label, testData.Features, cfos_model, '-b 0');
%     [cfos_predict_label_L, accuracy_L, dec_values_L] = ...
%        svmpredict(testData.Label, testData.Features, cfos_model_linear, '-b 1');
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
% cfos_model = svmtrain(cfos_label_vector, cfos_feature_vector,        '-c 5 -b 0  -t 0 -s 0');% 263/280
% cfos_model_linear = svmtrain(cfos_label_vector, cfos_feature_vector, '-c 5 -b 1  -t 0 -s 0');% 265/280


cfos_model = svmtrain(cfos_label_vector, cfos_feature_vector, '-c 15 -b 0 -t 0 -s 0');% 267/280
cfos_model_linear = svmtrain(cfos_label_vector, cfos_feature_vector, ' -b 1 -t 0 -s 0');% 267/280

% pca_model = svmtrain(cfos_label_vector, score, '-c 15 -b 0 -t 0 -s 0');% 267/280
% pca_model_linear = svmtrain(cfos_label_vector, score, ' -b 1 -t 0 -s 0');% 267/280
% 
% 


%  cfos_model_polynomial = svmtrain(cfos_label_vector, cfos_feature_vector, '-t 1');
%  cfos_model_RBF = svmtrain(cfos_label_vector, cfos_feature_vector, '-t 2');
%  cfos_model_sigmoid = svmtrain(cfos_label_vector, cfos_feature_vector, '-t 3');
% %
% tdt_model = svmtrain(tdt_label_vector, tdt_feature_vector, '-c 5 -b 0  -t 0 -s 0');
% tdt_model_linear = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 0');
% tdt_model_polynomial = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 1');
% tdt_model_RBF = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 2');
% tdt_model_sigmoid = svmtrain(tdt_label_vector, tdt_feature_vector, '-t 3');


%% test images

    [filename,pathname] = uigetfile('../images/new/test/*.tif', 'Select image file');
    cfos_test_image_path = [pathname, filename]

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];

    [filename,pathname] = uigetfile('../images/new/test/*.xlsx', 'Select tag file');
    test_tag_path = [pathname, filename]

    [cfos_test_feature_vector, cfos_test_label_vector] = extract_feature_and_import_tags(cfos_test_image_path, test_tag_path, 'cfos');
 



    % [tdt_test_feature_vector, tdt_test_label_vector] = extract_feature_and_import_tags(tdt_test_image_path, test_tag_path, 'tdt');



%% test model
% test_fn = '../data/leu.test';
% [test_label, test_data] = libsvmread(test_fn);

% test_data = Feature_vector;
% test_label = Label_vector;

% @predictd_label: is a vector of predicted labels.
% @accuracy, is a vector including accuracy (for classification), mean
%   squared error, and squared correlation coefficient (for regression).
% @matrix, containing decision values ([-1,0] -> -1, [0,1] -> 1)

[cfos_predict_label, accuracy, dec_values] = ...
       svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model, '-b 0');
[cfos_predict_label_L, accuracy_L, dec_values_L] = ...
       svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_linear, '-b 1');
%  [cfos_predict_label_P, accuracy_P, dec_values_P] = ...
%         svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_polynomial);
%  [cfos_predict_label_RBF, accuracy_RBF, dec_values_RBF] = ...
%         svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_RBF); 
%  [cfos_predict_label_S, accuracy_S, dec_values_S] = ...
%         svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_sigmoid); 
%   [cfos_predicted_label, accuracy, prob_estimates] = ... 
%        svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model, '-b 1');
%   
% [cfos_predict_label, accuracy, dec_values] = ...
%        svmpredict(cfos_test_label_vector, score_test, cfos_model, '-b 0');
% [cfos_predict_label_L, accuracy_L, dec_values_L] = ...
%        svmpredict(cfos_test_label_vector, score_test, cfos_model_linear, '-b 1');
% 
%    
   
% 
% [tdt_predict_label, accuracy, dec_valuesL] = ...
%        svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model);
% [tdt_predict_label_L, accuracy_L, dec_values_L] = ...
%        svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_linear);
% [tdt_predict_label_P, accuracy_P, dec_values_P] = ...
%        svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_polynomial);
% [tdt_predict_label_RBF, accuracy_RBF, dec_values_RBF] = ...
%        svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_RBF); 
% [tdt_predict_label_S, accuracy_S, dec_values_S] = ...
%        svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_sigmoid); 
% [tdt_predicted_label, accuracy, prob_estimates] = ... 
%       svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model, '-b 1');


%% analyze
cfos_mislabel = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, cfos_predict_label);
cfos_mislabel_L = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, cfos_predict_label_L);
% tdt_midlabel = check_mislabeled(tdt_test_image_path, tdt_test_label_vector, tdt_predict_label_L);

