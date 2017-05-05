clear all
close all
clc

%%
counter = 0;
answer = 'y';

cfos_feature_vector = [];
cfos_label_vector = [];
tdt_feature_vector = [];
tdt_label_vector = [];

while answer == 'y'
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
    
    answer = input('more images? y or n : ', 's');

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


%% test images
[filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
cfos_test_image_path = [pathname, filename];

[filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
tdt_test_image_path = [pathname, filename];

[filename,pathname] = uigetfile('../images/*.xlsx', 'Select tag file');
test_tag_path = [pathname, filename];

[cfos_test_feature_vector, cfos_test_label_vector] = extract_feature(cfos_test_image_path, test_tag_path, 'cfos');
[tdt_test_feature_vector, tdt_test_label_vector] = extract_feature(tdt_test_image_path, test_tag_path, 'tdt');



%% test model
% test_fn = '../data/leu.test';
% [test_label, test_data] = libsvmread(test_fn);

% test_data = Feature_vector;
% test_label = Label_vector;

% @predictd_label: is a vector of predicted labels.
% @accuracy, is a vector including accuracy (for classification), mean
%   squared error, and squared correlation coefficient (for regression).
% @matrix, containing decision values ([-1,0] -> -1, [0,1] -> 1)

[cfos_predict_label, accuracy, dec_valuesL] = ...
       svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model);
[cfos_predict_label_L, accuracy_L, dec_values_L] = ...
       svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_linear);
[cfos_predict_label_P, accuracy_P, dec_values_P] = ...
       svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_polynomial);
[cfos_predict_label_RBF, accuracy_RBF, dec_values_RBF] = ...
       svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_RBF); 
[cfos_predict_label_S, accuracy_S, dec_values_S] = ...
       svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_sigmoid); 
 [cfos_predicted_label, accuracy, prob_estimates] = ... 
      svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model, '-b 1');
%  


[tdt_predict_label, accuracy, dec_valuesL] = ...
       svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model);
[tdt_predict_label_L, accuracy_L, dec_values_L] = ...
       svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_linear);
[tdt_predict_label_P, accuracy_P, dec_values_P] = ...
       svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_polynomial);
[tdt_predict_label_RBF, accuracy_RBF, dec_values_RBF] = ...
       svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_RBF); 
[tdt_predict_label_S, accuracy_S, dec_values_S] = ...
       svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model_sigmoid); 
[tdt_predicted_label, accuracy, prob_estimates] = ... 
      svmpredict(tdt_test_label_vector, tdt_test_feature_vector, tdt_model, '-b 1');


%% analyze
cfos_mislabel = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, cfos_predict_label);
tdt_midlabel = check_mislabeled(tdt_test_image_path, tdt_test_label_vector, tdt_predict_label);

