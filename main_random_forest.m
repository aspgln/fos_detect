%% import all data

% select multiple image and tag files
[filename,pathname] = uigetfile('../data/DH/cfos/*.tif', ...
   'Select image file', 'MultiSelect', 'on' );

% store file paths in a vector
cfos_image_path_vector = strcat(pathname, filename(:)); 


[filename,pathname] = uigetfile('../data/DH/tag/*.xlsx', ...
    'Select image file', 'MultiSelect' , 'on');
tag_path_vector = strcat(pathname, filename(:));

%% 
% randomly select 10 as test images
m = length(cfos_image_path_vector);

test_index = randsample(1:m, 10);

test_image_path_vector = cfos_image_path_vector(test_index);
test_tag_path_vector = tag_path_vector(test_index);
train_image_path_vector = setdiff(cfos_image_path_vector,test_image_path_vector );
train_image_tag_vector = setdiff(tag_path_vector,test_tag_path_vector );

%% extract features and labels from training data
    training_BW_patch_vector = [];
    training_Gray2_patch_vector = [];  
    training_Label_vector = [];      
    training_Feature_vector = [];
 

tic
for i = 1: length(train_image_tag_vector)
    % track time
    remain_time = (toc / i) * (length(train_image_tag_vector)-i);
    
    % track elapsed time
    s = sprintf(' %d / %d \n time used: %.2f \n time remains %.2f \n', i,length(train_image_tag_vector), toc, remain_time);     
    fprintf(s);  
    
%     % extract patches from each image
%     [ Labels, training_BW_patch, ~, training_Gray2_patch]...                       
%         = create_pixel_features(train_image_path_vector{i}, train_image_tag_vector{i}, 'cfos');
   % extract features
    [Features, Labels] = extract_feature_and_import_tags...
       (train_image_path_vector{i}, train_image_tag_vector{i}, 'cfos');
    
    
    
    
%     BW_patch_vector = [BW_patch_vector   BW_patch];
%     Gray2_patch_vector = [Gray2_patch_vector   Gray2_patch];  
    training_Label_vector = [training_Label_vector;  Labels];      
    training_Feature_vector = [training_Feature_vector; Features];
end
 

featureData = struct('Feature',training_Feature_vector, 'Label', training_Label_vector );

%% save features
save('/Users/qingdai/Desktop/fos_detection/data/featureData(Shape + Texture + LBP + HOG_25).mat' , ...
    'featureData');

%% load features
feature_path = '/Users/qingdai/Desktop/fos_detection/data/featureData(Shape + Texture + LBP + HOG_25).mat';
a = load(feature_path);
a = a.featureData;

training_Feature_vector = a.Feature;
training_Label_vector = a.Label;



%% set indices and cross validation


m = length(training_Feature_vector);

% find the indices of all positive signals
positive_index = find(training_Label_vector);

% find the indices of all negative signals
negative_index = setdiff(1:m, positive_index);

% randomly choose subsamples to balance data
% negInd = randsample(negative_index, length(positive_index));
 negInd = randsample(negative_index, length(positive_index));


% combine and shuffle subsample
total_index = [positive_index; negInd'];
total_index = total_index(randperm(length(total_index)));

% set k-fold validation
k = 5;
cv = cvpartition(total_index, 'kfold', k);

%% train and test 

result = zeros(9,k);
for i = 1:k
    
    disp(i)
    
    % divide into two subsets
    trainInd = total_index(training(cv,i));
    valInd  = total_index(test(cv,i));

    trainFeatures = training_Feature_vector(trainInd,:);
    trainLabels = training_Label_vector(trainInd(1:end), :);
    
    valFeatures = training_Feature_vector(valInd(1:end), :);
    valLabels = training_Label_vector(valInd(1:end), :);
    
    % train
    
    % random number generation
    rng(1);
    
    Model = TreeBagger(200,trainFeatures,trainLabels,'OOBPrediction',...
        'On', 'Method','classification');

%     
    % predict
    [predict_labels, score, stdevs] = predict(Model,valFeatures);
    predict_labels = str2double(predict_labels);
    
    % check accuracy
    % r stores tp, fp, fn, precision, recall, accuracy, and print the
    % console
    [r, f1_score] = check_accuracy(valLabels, predict_labels);
    
    % ROC curve
    [X,Y,T,AUC,OPTROCPT,SUBY] = perfcurve(valLabels,score(:,2), 1, 'XCrit','fall', 'YCrit','sens');
    figure;plot(X,Y);
    
    [X2,Y2,T,AUC2,OPTROCPT,SUBY] = perfcurve(valLabels,score(:,2), 1, 'XCrit','reca', 'YCrit','prec');
    figure;plot(X2,Y2);
    
        result(:,i) =  [r(1:end); AUC; AUC2; f1_score];

    % visualize model
%      view(Model_1.Trees{1},'Mode','graph')
%      view(Model_1.Trees{1})

%      figure;
%      oobErrorBaggedEnsemble = oobError(Model);
%      plot(oobErrorBaggedEnsemble)
%      xlabel 'Number of grown trees';
%      ylabel 'Out-of-bag classification error';
%    	
    	
end

disp('avg');
avg = mean(result,2);
disp(avg);



%% save model

save('/Users/qingdai/Desktop/fos_detection/model/RF200_min25_(Shape+texture+LBP+HOG)_+=-=4959' , ...
    'Model');
save('/Users/qingdai/Desktop/fos_detection/model/model_RF(5154_3000_<25).mat' , ...
    'Model_1', 'Model_2', 'Model_3', 'Model_4', 'Model_5');


%% select model
[filename,pathname] = uigetfile('../model/*.mat', ...
   'Select model' );
modelPath = [pathname, filename];
a = load(modelPath);


%% test model

predict_model = Model;

test_Features = [];
test_Labels = [];
predict_Labels = [];
score = [];
result = [];

for i = 1:length(test_image_path_vector)
   disp(i)
   [Features, Labels] = extract_feature_and_import_tags...
         (test_image_path_vector{i}, test_tag_path_vector{i}, 'cfos');
         

    test_Labels = [test_Labels; Labels];
    
    [pre, s] = predict(predict_model,Features);
    pre = str2double(pre);
    predict_Labels = [predict_Labels ;pre];
   
    
    score = [score; s];
    [r, f1_score] = check_accuracy(Labels, pre);
    r = [r;f1_score];
    result = [result r]; 

    % total number of positive candidates predicted 
    num_of_predict(i) = length(find(pre));
    
    % total number of true positive candidates
    num_of_true(i) = length(find(Labels));
    


end
x = 1:10;
figure;plot(x,num_of_predict, x, num_of_true );

avg = mean(result, 2);




[X,Y,T,AUC,OPTROCPT,SUBY] = perfcurve(test_Labels,score(:,2), 1);
figure;plot(X,Y);
xlabel('False positive rate')
ylabel('True positive rate')

[X2,Y2,T,AUC2,OPTROCPT,SUBY] = perfcurve(test_Labels,score(:,2), 1, 'XCrit','reca', 'YCrit','prec');
figure;plot(X2,Y2);
xlabel('Recall')
ylabel('Precision')
%% analyze
cfos_mislabel = check_mislabeled(test_image_path_vector{i}, Labels, pre);
% % tdt_midlabel = check_mislabeled(tdt_test_image_path, tdt_test_label_vector, tdt_predict_label_L);

