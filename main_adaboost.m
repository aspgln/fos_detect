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

%% load features
feature_path = '/Users/qingdai/Desktop/fos_detection/data/featureData(I_bw).mat';
a = load(feature_path);
a = a.featureData;

Feature_vector = a.Feature;
Label_vector = a.Label;
%% cross validation

m = length(Feature_vector);

% find the indices of all positive signals
positive_index = find(Label_vector);

% find the indices of all negative signals
negative_index = setdiff(1:m, positive_index);

% randomly choose subsamples to balance data
% negInd = randsample(negative_index, length(positive_index));
% negInd = randsample(negative_index, 6970);


% combine and shuffle subsample
total_index = [positive_index; negative_index'];
% total_index = [positive_index; negative_index'];

total_index = total_index(randperm(length(total_index)));

% set k-fold validation
k = 5;
cv = cvpartition(total_index, 'kfold', k);



%% train images 

result_1 = zeros(6,k);
result_2 = zeros(6,k);
result_3 = zeros(6,k);
result_4 = zeros(6,k);
result_5 = zeros(6,k);

for i = 1:k 
    disp(i)
    % divide into two subsets by indices
    trainInd = total_index(training(cv,i));
    testInd  = total_index(test(cv,i));
    
    trainFeatures = Feature_vector(trainInd(1:end), :);
    trainLabels = Label_vector(trainInd(1:end), :);
    
    testFeatures = Feature_vector(testInd(1:end), :);
    testLabels = Label_vector(testInd(1:end), :);
    
    trainLabels(trainLabels == 0) =  -1;
    
  
    
    % train 
    

    1
    [estimateclasstotal_1,model_adaboost_1] = adaboost('train',...
    trainFeatures,trainLabels,10);
2
    [estimateclasstotal_2,model_adaboost_2] = adaboost('train',...
    trainFeatures,trainLabels,20);
3
    [estimateclasstotal_3,model_adaboost_3] = adaboost('train',...
    trainFeatures,trainLabels,30);
4
    [estimateclasstotal_4,model_adaboost_4] = adaboost('train',...
    trainFeatures,trainLabels,40);
5
    [estimateclasstotal_5,model_adaboost_5] = adaboost('train',...
   trainFeatures,trainLabels,50);

    % predict
    predict_label_1 = adaboost('apply',testFeatures,model_adaboost_1);
    predict_label_2 = adaboost('apply',testFeatures,model_adaboost_2);
    predict_label_3 = adaboost('apply',testFeatures,model_adaboost_3);
    predict_label_4 = adaboost('apply',testFeatures,model_adaboost_4);
    predict_label_5 = adaboost('apply',testFeatures,model_adaboost_5);

    predict_label_1(predict_label_1 == -1) = 0;
    predict_label_2(predict_label_2 == -1) = 0;
    predict_label_3(predict_label_3 == -1) = 0;
    predict_label_4(predict_label_4 == -1) = 0;
    predict_label_5(predict_label_5 == -1) = 0;

    r = check_accuracy(testLabels, predict_label_1);
    result_1(:, i) = r;		
    r = check_accuracy(testLabels, predict_label_2);
    result_2(:, i) = r;	
    r = check_accuracy(testLabels, predict_label_3);
    result_3(:, i) = r;	
    r = check_accuracy(testLabels, predict_label_4);
    result_4(:, i) = r;	
    r = check_accuracy(testLabels, predict_label_5);
    result_5(:, i) = r;	
end

avg = mean(result_1,2);
result_1 =  [result_1 avg];	
avg = mean(result_2,2);
result_2 =  [result_2 avg];	
avg = mean(result_3,2);
result_3 =  [result_3 avg];	
avg = mean(result_4,2);
result_4 =  [result_4 avg];	
avg = mean(result_5,2);
result_5 =  [result_5 avg];	

%% save model

save('/Users/qingdai/Desktop/fos_detection/model/model_AdaB(I_bw).mat' , ...
    'model_adaboost_1', 'model_adaboost_2', 'model_adaboost_3', ...
    'model_adaboost_4', 'model_adaboost_5');

