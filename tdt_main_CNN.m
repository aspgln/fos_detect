
%% load images

% select multiple image and tag files2
% [filename,pathname] = uigetfile('../images/new/DH/data/tdt/*.tif', ...
%     'Select image file', 'MultiSelect', 'on' );
[filename,pathname] = uigetfile('../data/DH/tdt/*.tif', ...
   'Select image file', 'MultiSelect', 'on' );
% store file paths in a vector
tdt_image_path_vector = strcat(pathname, filename(:)); 


[filename,pathname] = uigetfile('../data/DH/tag/*.xlsx', ...
    'Select image file', 'MultiSelect' , 'on');
tag_path_vector = strcat(pathname, filename(:));
%% 
% randomly select 10 as test images from all images 
m = length(tdt_image_path_vector);

% track images by their indices
test_index = randsample(1:m, 20);

% store test images and test tag path in a vector
test_image_path_vector = tdt_image_path_vector(test_index);
test_tag_path_vector = tag_path_vector(test_index);

% store train images and test tag path in a vector
train_image_path_vector = setdiff(tdt_image_path_vector,test_image_path_vector );
train_image_tag_vector = setdiff(tag_path_vector,test_tag_path_vector );

%% 

training_Label_vector = [];      
training_BW_patch_vector = [];
training_Gray_patch_vector = [];

% extract patches from each image, extract labels
tic
for i = 1: length(train_image_path_vector)
    % track time
    remain_time = (toc / i) * (length(train_image_path_vector)-i);
    
    s = sprintf(' %d / %d \n time used: %.2f \n time remains %.2f \n', i,length(train_image_path_vector), toc, remain_time);     
    fprintf(s);  
    
    % extract patches from each image
    [ labels, BW_patch, ~, Gray_patch]...                       
        = tdt_create_pixel_features(train_image_path_vector{i}, train_image_tag_vector{i}, 'tdt');

      
    
    
    training_BW_patch_vector = [training_BW_patch_vector   BW_patch];
    training_Gray_patch_vector = [training_Gray_patch_vector   Gray_patch];  
    training_Label_vector = [training_Label_vector;  labels];      
    
end
    
 %% create data structure

% store all patches and corresponding in imageData 
imageData = struct('BW', training_BW_patch_vector, 'Gray', training_Gray_patch_vector, ...
    'Label', training_Label_vector);  
% save('/Users/qingdai/Desktop/fos_detection/data/imageData.mat' , ...
%     'imageData');
%% load imageData


% 
% feature_path = '/Users/qingdai/Desktop/fos_detection/data/imageData.mat';
% a = load(feature_path);
% imageData = a.imageData;
% 
training_BW_patch_vector = imageData.BW;
training_Gray_patch_vector = imageData.Gray;

training_Label_vector = imageData.Label;      

%% cross validation
m = length(training_BW_patch_vector); 

% find the indices of all positive signals
positive_index = find(training_Label_vector);

% find the indices of all negative signals
negative_index = setdiff(1:m, positive_index);


% randomly choose subsamples to balance data
% posInd = randsample(positive_index, 2500);
negInd = randsample(negative_index, length(positive_index));
% negInd = randsample(negative_index, length(positive_index));


% combine and shuffle subsample
total_index = [positive_index; negInd'];
% total_index = [positive_index; negative_index'];

total_index = total_index(randperm(length(total_index)));



% set k-fold validation
k = 5;
cv = cvpartition(total_index, 'kfold', k);
% cv = cvpartition(subtotal_index, 'kfold', k);

% % divide into three subsets with random indices      
% [trainInd,testInd] = dividerand(Q,80,20); 



    
%% specify layers

% image input layer
% data augmentation is used to reduce overfitting
inputlayer = imageInputLayer([61, 61, 1] );

% convolutional layer
% filter size and Filters are random
convlayer = convolution2dLayer([4,4],7,'Stride',1);

convlayer2 = convolution2dLayer([4,4],7,'Stride',1);

% RELU layer
relulayer = reluLayer();

% pooling layer
maxpoollayer = maxPooling2dLayer([2,2], 'Stride', 1);
avgpoollayer = averagePooling2dLayer([2,2], 'Stride', 1);

% dropout layer
droplayer = dropoutLayer();

% fully conncected layer, 2 classes
fullconnectlayer = fullyConnectedLayer(2);

% softmax layer
smlayer = softmaxLayer();

% classification layer
coutputlayer = classificationLayer();


% construct layers
layers = [inputlayer
          convlayer
          relulayer
%            convlayer2
%            relulayer
          maxpoollayer
%           avgpoollayer
          droplayer
%           fullconnectlayer
           fullconnectlayer
          smlayer
          coutputlayer];
      




%% learn
val_result = zeros(9,k);

tic
for i = 1:2
    % divide into two subsets by indices
    trainInd = total_index(training(cv,i));
    valInd  = total_index(test(cv,i));
%     trainInd = subtotal_index(training(cv,i));
%     testInd  = subtotal_index(test(cv,i));
    
    % IMPROVE: get from patch_vector by indices to save stack space
    
    
    trainData = struct('BW', training_BW_patch_vector(trainInd), 'Gray', ...
      training_Gray_patch_vector(trainInd), 'Label', training_Label_vector(trainInd));                                   

    valData = struct('BW', training_BW_patch_vector(valInd(1:end)), 'Gray', ...
      training_Gray_patch_vector(valInd), 'Label', training_Label_vector(valInd));  
  
    % create 4-D image array (height, width, channel, index)		 +  % create 4-D image array
    % X: training data, 		
    % Y: traning label    
    
    X = zeros(61,61,1,length(trainData.Gray));
    for j = 1:length(trainData.Gray)
        
        X(:,:,1, j) = trainData.Gray(j).image;
    end

    Y = categorical(trainData.Label);

    
    functions = { ...
     % plot real-time mini-batch accuracy		
    @plot_training_accuracy, ...
     % stop training when accuracy reach threshold		
    @(info) stop_training_at_threshold(info,95)};

%     options = trainingOptions('sgdm', 'InitialLearnRate',0.03, ...
%         'LearnRateSchedule', 'piecewise', 'LearnRateDropFactor', 0.2,...
%          'LearnRateDropPeriod',5, 'MaxEpochs',10, 'OutputFcn',functions);
%     
  % specify training options		
    options = trainingOptions('sgdm', 'InitialLearnRate',0.008);

    % tracking
    s = sprintf('%d / %d ', i, k);
    fprintf(s); 
    
    
    % train net
    trainedNet(i) = trainNetwork(X, Y, layers,options);
% time tracking
    remain_time = (toc / i) * (k-i);
    s = sprintf('time used: %.2f \n time remains: %.2f \n', toc, remain_time);
    fprintf(s);
  
  
  
  % Validation
    
  % XVal: testing data
    XVal = zeros(61,61,1,length(valData.Gray));
    
    for j = 1:length(valData.Gray)
        XVal(:,:,1, j) = valData.Gray(j).image;
    end



    % predict
    % YVal is predict label
    % TVal is true label
    [YVal,score] = classify(trainedNet(i),XVal);
    TVal = categorical(valData.Label);

   
    % ROC curve
    [X,Y,T,AUC,OPTROCPT,SUBY] = perfcurve(valData.Label,score(:,2), 1, 'XCrit','fall', 'YCrit','sens');
    figure;plot(X,Y);
    
     % Precision/Recall curve
    [X2,Y2,T,AUC2,OPTROCPT,SUBY] = perfcurve(valData.Label,score(:,2), 1, 'XCrit','reca', 'YCrit','prec');
    figure;plot(X2,Y2);
    
    predict_labels = double(YVal);
    predict_labels(predict_labels == 1) = 0;
    predict_labels(predict_labels == 2) = 1;

    %  peformance 
    
    [r, f1_score] = check_accuracy(valData.Label, predict_labels);

    val_result(:,i) =  [r(1:end); AUC; AUC2; f1_score];

    	
  
  
end
                     
disp('avg');
avg = mean(val_result,2);
disp(avg);

    
   
 %% save model

 save('/Users/qingdai/Desktop/fos_detection/model/model_CNN_tdt.mat' , ...
     'trainedNet');
% 
% save('/Users/qingdai/Desktop/fos_detection/data/imageData(60).mat' , ...
%     'imageData');


predict_model = trainedNet(1);

%% %% test model

% initialization
test_Features = [];
test_Labels = [];
predict_Labels = [];
score = [];
result = [];

for i = 1:length(test_image_path_vector)
   disp(i)
   
   % extract features and labels from the vectors created in the second
   % section
    [ Labels, BW_patch, ~, Gray_patch]...                       
        = tdt_create_pixel_features(test_image_path_vector{i}, test_tag_path_vector{i}, 'tdt');
         
    % concatenate true labels among iterations
    test_Labels = [test_Labels; Labels];
    
    
    XTest = zeros(61,61,1,length(BW_patch));
    
    for j = 1:length(BW_patch)
        XTest(:,:,1, j) = Gray_patch(j).image;
    end



    % predict
    % YVal is predict label
    % TVal is true label
    [YTest,s] = classify(predict_model,XTest);
    YTest = double(YTest);
    YTest(YTest == 1) = 0;
    YTest(YTest == 2) = 1;

    % concatenate predict labels among iterations
    predict_Labels = [predict_Labels ;YTest];
   
    % concatenate score/probability among iterations
    score = [score; s];
    
    % check test accuracy
    % r stores tp, fp, fn, precision, recall, accuracy,f1_score and print to the
    % console
    [r, f1_score] = check_accuracy(Labels, YTest);
    r = [r;f1_score];
    result = [result r]; 

    % total number of positive candidates predicted 
    num_of_predict(i) = length(find(YTest));
    
    % total number of true positive candidates
    num_of_true(i) = length(find(Labels));
    


end

% plot true/predicted number of positive signals
x = 1:20;
figure;plot(x,num_of_predict, x, num_of_true );
xlabel('image index')
ylabel('number of positive signals')

avg = mean(result, 2);



% ROC Curve
% TPR vs FPR = sensitivity vs (1-specificity) = TP/(TP+FN) vs FP/(FP+TN)
[X,Y,T,AUC,OPTROCPT,SUBY] = perfcurve(test_Labels,score(:,2), 1,'XCrit','fall', 'YCrit','sens');
figure;plot(X,Y);
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC Curve')

% Precision/Recall curve
% TP/(TP+FP) vs TP/(TP+FN) 
[X2,Y2,T,AUC2,OPTROCPT,SUBY] = perfcurve(test_Labels,score(:,2), 1, 'XCrit','reca', 'YCrit','prec');
figure;plot(X2,Y2);
xlabel('Recall')
ylabel('Precision')
title('PR curve')


%% analyze
% visualize result on image
mislabel = check_mislabeled(test_image_path_vector{i}, Labels, YTest);

    
    
 
    
