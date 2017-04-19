


%% read train data
% raw data is a sparse matrix

% train_fn = '../data/leu.train';

% convert full matrix to sparse matrix

% training_matrix_full = sparse(full_training_matrix);
% train_sparse = sparse(Feature_vector);
% [train_label, train_data] = libsvmread(train_fn);
train_data = Feature_vector;
train_label = Label_vector;
%% train model
% -s svm_type 
% -t kernel_type 
% -b probability_estimates 0 for SVC
% -c cost parameter
% -g gamma

% model = svmtrain(train_label, train_data, '-c 1 -b 1 -t 0 -s 0');
model = svmtrain(train_label, train_data, '-c 5 -b 0  -t 0 -s 0');



% % Linear Kernel
model_linear = svmtrain(train_label, train_data, '-t 0');
% 
% % Polynomical Kernal
model_polynomial = svmtrain(train_label, train_data, '-t 1');
% 
% % RBF/Gaussian Kernal
model_RBF = svmtrain(train_label, train_data, '-t 2');
% 
% % Sigmoid Kernal
model_sigmoid = svmtrain(train_label, train_data, '-t 3');



%

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


