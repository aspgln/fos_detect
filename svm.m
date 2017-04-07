
clear all
close all
clc

%% read train data
% raw data is a sparse matrix
train_fn = '../data/leu.train';

% convert full matrix to sparse matrix
% training_matrix_full = sparse(full_training_matrix);

[train_label, train_data] = libsvmread(train_fn);

%% train model
% -s svm_type 
% -t kernel_type 
% -b probability_estimates 0 for SVC
% -c cost parameter
% -g gamma

% model = svmtrain(train_label, train_data, '-c 1 -b 1 -t 0 -s 0');
model = svmtrain(train_label, train_data, '-c 1 -b 0 -t 0 -s 0');



% % Linear Kernel
% model_linear = svmtrain(train_label, train_data, '-t 0');
% 
% % Polynomical Kernal
% model_polynomial = svmtrain(train_label, train_data, '-t 1');
% 
% % RBF/Gaussian Kernal
% model_RBF = svmtrain(train_label, train_data, '-t 2');
% 
% % Sigmoid Kernal
% model_sigmoid = svmtrain(train_label, train_data, '-t 3');



%

%% test model
test_fn = '../data/leu.test';

[test_label, test_data] = libsvmread(test_fn);

% @predictd_label: is a vector of predicted labels.
% @accuracy, is a vector including accuracy (for classification), mean
%   squared error, and squared correlation coefficient (for regression).
% @matrix, containing decision values ([-1,0] -> -1, [0,1] -> 1)

[predict_label, accuracy, dec_valuesL] = ...
       svmpredict(test_label, test_data, model);

% [predict_label_L, accuracy_L, dec_values_L] = ...
%        svmpredict(test_label, test_data, model_linear);
%    
% [predict_label_P, accuracy_P, dec_values_P] = ...
%        svmpredict(test_label, test_data, model_polynomial);
%       
% [predict_label_RBF, accuracy_RBF, dec_values_RBF] = ...
%        svmpredict(test_label, test_data, model_RBF); 
%    
% [predict_label_S, accuracy_S, dec_values_S] = ...
%        svmpredict(test_label, test_data, model_sigmoid); 
%    
% [predicted_label, accuracy, prob_estimates] = ... 
%     svmpredict(test_label, test_data, model, '-b 1');






%% predict

% %% write
% test_data_full = full(test_data);
% libsvmwrite('../data/output.txt', predicted_label, test_data);

