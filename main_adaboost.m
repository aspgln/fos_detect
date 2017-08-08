%% extract features


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


%% cross validation

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



%% train images 

result = zeros(6,k);

for i = 1:k 
    disp(i)
    % divide into two subsets by indices
    trainInd = total_index(training(cv,i));
    testInd  = total_index(test(cv,i));
    
    
    trainData = struct('Features', Feature_vector(trainInd(1:end), :),...
        'Label', Label_vector(trainInd(1:end)));
    testData = struct('Features', Feature_vector(testInd(1:end), :),...
        'Label', Label_vector(testInd(1:end)));
    
    trainData.Label(trainData.Label == 0) =  -1;
    
  
    
    % train 
    
    adaboost_train_features = trainData.Features;
    adaboost_train_labels = trainData.Label;
    
%     adaboost_train_labels (adaboost_train_labels == 0) =  -1;
    
    [estimateclasstotal,model_adaboost_1] = adaboost('train',adaboost_train_features,adaboost_train_labels,10);
    
    
    
    % test
    cfos_test_feature_vector = testData.Features;
    adaboost_predict_label_1 = adaboost('apply',cfos_test_feature_vector,model_adaboost_1);

    adaboost_predict_label_1(adaboost_predict_label_1 == -1) = 0;
    
    
    
    cfos_test_label_vector = testData.Label;


    tp = 0;
    fp = 0;
    fn = 0;
    tn = 0;


    for j = 1:length(adaboost_predict_label_1)
        if (cfos_test_label_vector(j) == 1) && (adaboost_predict_label_1(j) == 1)
            tp = tp + 1;
        elseif (cfos_test_label_vector(j) == 1) && (adaboost_predict_label_1(j) == 0)
            fn = fn + 1;
        elseif (cfos_test_label_vector(j) == 0) && (adaboost_predict_label_1(j) == 1)
            fp = fp + 1    ;
        elseif (cfos_test_label_vector(j) == 0) && (adaboost_predict_label_1(j) == 0)
            tn = tn + 1;
        end 

    end

    precision = tp / (tp + fp);

    recall =  tp / (tp + fn);

    accuracy = (tp + tn) / (tp + tn + fp + fn );


    x = {'model 1', ''; 
        'tp', tp; 'fp', fp; 'fn', fn;
        'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


    r = cell2mat(x(2:7,2));
   disp(r);
  result(:, i) = r;		
  
  
end

output = mean(result,2);
disp(output);


