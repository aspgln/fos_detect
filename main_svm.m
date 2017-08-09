clear all
close all
clc

%% import images


Feature_vector = [];
Label_vector = [];



% select multiple image and tag files2
% [filename,pathname] = uigetfile('../images/new/DH/data/cfos/*.tif', ...
%     'Select image file', 'MultiSelect', 'on' );
[filename,pathname] = uigetfile('../data/DH/cfos/*.tif', ...
   'Select image file', 'MultiSelect', 'on' );
% store file paths in a vector
cfos_image_path_vector = strcat(pathname, filename(:)); 


[filename,pathname] = uigetfile('../data/DH/tag/*.xlsx', ...
    'Select image file', 'MultiSelect' , 'on');
tag_path_vector = strcat(pathname, filename(:));

%% extract features 

% extract patches from each image, extract labels
l = length(filename);
tic
for i = 1: l
    % track time
    remain_time = (toc / i) * (l-i);
    
    s = sprintf(' %d / %d \n time used: %.2f \n time remains %.2f \n', i,l, toc, remain_time);    fprintf(s);   
    fprintf(s);  
    
     [Features, Labels] = extract_feature_and_import_tags...
         (cfos_image_path_vector{i}, tag_path_vector{i}, 'cfos');
    
    
    
    Feature_vector = [Feature_vector; Features];
    Label_vector = [Label_vector;  Labels];      
    
end



%% set indices and cross validation


m = length(Feature_vector);

% find the indices of all positive signals
positive_index = find(Label_vector);

% find the indices of all negative signals
negative_index = setdiff(1:m, positive_index);

% randomly choose subsamples to balance data
negInd = randsample(negative_index, length(positive_index));

% combine and shuffle subsample
total_index = [positive_index; negInd'];
total_index = total_index(randperm(length(total_index)));

% set k-fold validation
k = 5;
cv = cvpartition(total_index, 'kfold', k);


%% train and test

result_1 = zeros(6,k);
result_2 = zeros(6,k);

for i = 1:k
    disp(i)
    
    % divide into two subsets
    trainInd = total_index(training(cv,i));
    testInd  = total_index(test(cv,i));
    
    trainFeatures = Feature_vector(trainInd(1:end), :);
    trainLabels = Label_vector(trainInd(1:end), :);
    
    testFeatures = Feature_vector(testInd(1:end), :);
    testLabels = Label_vector(testInd(1:end), :);
    
    
    % train
    
    % -s svm_type 
    % -t kernel_type 
    % -b probability_estimates 0 for SVC
    % -c cost parameter
    % -g gamma

    model_1 = svmtrain(trainLabels, trainFeatures,'-c 15 -b 0 -t 0 -s 0' );
    model_2 = svmtrain(trainLabels, trainFeatures,' -b 1 -t 0 -s 0' );

    % test 
    [predictLabels_1, accuracy_1, dec_values_1] = ...
        svmpredict(testLabels, testFeatures, model_1,  '-b 0');
     [predictLabels_2, accuracy_2, dec_values_2] = ...
        svmpredict(testLabels, testFeatures, model_2,  '-b 1');
    
    % accuracy 
    
    % model 1
    tp = 0;
    fp = 0;
    fn = 0;
    tn = 0;


    for j = 1:length(predictLabels_1)
        if (testLabels(j) == 1) && (predictLabels_1(j) == 1)
            tp = tp + 1;
        elseif (testLabels(j) == 1) && (predictLabels_1(j) == 0)
            fn = fn + 1;
        elseif (testLabels(j) == 0) && (predictLabels_1(j) == 1)
            fp = fp + 1    ;
        elseif (testLabels(j) == 0) && (predictLabels_1(j) == 0)
            tn = tn + 1;
        end 

    end

    precision = tp / (tp + fp);

    recall =  tp / (tp + fn);

    accuracy = (tp + tn) / (tp + tn + fp + fn );


    x = {'SVM Model 1', ''; 
        'tp', tp; 'fp', fp; 'fn', fn;
        'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


    r = cell2mat(x(2:7,2));
    disp('model 1')
    disp(r);
    result_1(:, i) = r;		
    
    
    % model 2
    tp = 0;
    fp = 0;
    fn = 0;
    tn = 0;


    for j = 1:length(predictLabels_2)
        if (testLabels(j) == 1) && (predictLabels_2(j) == 1)
            tp = tp + 1;
        elseif (testLabels(j) == 1) && (predictLabels_2(j) == 0)
            fn = fn + 1;
        elseif (testLabels(j) == 0) && (predictLabels_2(j) == 1)
            fp = fp + 1    ;
        elseif (testLabels(j) == 0) && (predictLabels_2(j) == 0)
            tn = tn + 1;
        end 

    end

    precision = tp / (tp + fp);

    recall =  tp / (tp + fn);

    accuracy = (tp + tn) / (tp + tn + fp + fn );


    x = {'SVM Model 2', ''; 
        'tp', tp; 'fp', fp; 'fn', fn;
        'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


    r = cell2mat(x(2:7,2));
    disp('model 2')
    disp(r);
    result_2(:, i) = r;		
end

disp('avg:');
output = mean(result_1,2);
disp(output);

output = mean(result_2,2);
disp(output);



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




%% test model
% test_fn = '../data/leu.test';
% [test_label, test_data] = libsvmread(test_fn);

% test_data = Feature_vector;
% test_label = Label_vector;

% @predictd_label: is a vector of predicted labels.
% @accuracy, is a vector including accuracy (for classification), mean
%   squared error, and squared correlation coefficient (for regression).
% @matrix, containing decision values ([-1,0] -> -1, [0,1] -> 1)

% [cfos_predict_label, accuracy, dec_values] = ...
%        svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model, '-b 0');
% [cfos_predict_label_L, accuracy_L, dec_values_L] = ...
%        svmpredict(cfos_test_label_vector, cfos_test_feature_vector, cfos_model_linear, '-b 1');
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

