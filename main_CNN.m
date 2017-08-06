%% load images
% digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
%         'nndatasets','DigitDataset');
% digitData = imageDatastore(digitDatasetPath, ...
%         'IncludeSubfolders',true,'LabelSource','foldernames');
% CountLabel = digitData.countEachLabel;
% 


%% set default

BW_patch_vector = [];
Gray1_patch_vector = [];
Gray2_patch_vector = [];

label_vector = [];


%%

% 
% d = uigetdir('../data/', 'select a folder');
% files = dir(fullfile(d, '*.tif'));


%% load images

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
    [ ~, ~, ~, labels, BW_patch, ~, Gray2_patch]...                       
        = create_pixel_features(cfos_image_path_vector{i}, tag_path_vector{i}, 'cfos');

    BW_patch_vector = [BW_patch_vector   BW_patch];
    Gray2_patch_vector = [Gray2_patch_vector   Gray2_patch];         
    label_vector = [label_vector;  labels];      

end
    
 %% create data structure

% store all patches and corresponding in imageData 
imageData = struct('BW', BW_patch_vector, 'Gray', Gray2_patch_vector, ...
    'label', label_vector);  



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
total_index=total_index(randperm(length(total_index)));


% set k-fold validation
k = 5;
cv = cvpartition(total_index, 'kfold', k);

% % divide into three subsets with random indices      
% [trainInd,testInd] = dividerand(Q,80,20); 



    
%% specify layers

% image input layer
% data augmentation is used to reduce overfitting
inputlayer = imageInputLayer([41, 41, 1] );

% convolutional layer
% filter size and Filters are random
convlayer = convolution2dLayer([4,4],10,'Stride',1);

convlayer2 = convolution2dLayer([4,4],10,'Stride',1);

% RELU layer
relulayer = reluLayer();

% pooling layer
maxpoollayer = maxPooling2dLayer([2,2], 'Stride', 1);
% avgpoollayer = averagePooling2dLayer([2,2], 'Stride', 1);

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
%           relulayer
%           convlayer2
%           relulayer
          maxpoollayer
%           avgpoollayer
%           droplayer
          fullconnectlayer
          smlayer
          coutputlayer];
      




%% learn
result = zeros(6,5);
tic
for i = 1:k
    % divide into two subsets by indices
    trainInd = total_index(training(cv,i));
    testInd  = total_index(test(cv,i));

    % IMPROVE: get from patch_vector by indices to save stack space
    trainData = struct('BW', imageData.BW(trainInd(1:end)), 'Gray', ...
      imageData.Gray(trainInd(1:end)), 'label', imageData.label(trainInd(1:end)));                                   

    testData = struct('BW', imageData.BW(testInd(1:end)), 'Gray', ...
      imageData.Gray(testInd(1:end)), 'label', imageData.label(testInd(1:end)));  
  
  
  % create 4-D image array (height, width, channel, index)		 +  % create 4-D image array
   % X: training data, 		
  % Y: traning label    
  X = zeros(41,41,1,length(trainData.BW));
    for j = 1:length(trainData.BW)
        X(:,:,1, j) = trainData.BW(j).image;
    end

    Y = categorical(trainData.label);

    
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
    options = trainingOptions('sgdm', 'OutputFcn',functions);
    
    % tracking
    s = sprintf('%d / %d ', i, k);
    fprintf(s); 
    
    
    % train net
    trainedNet = trainNetwork(X, Y,layers,options);

% time tracking
    remain_time = (toc / i) * (k-i);
    s = sprintf('time used: %.2f \n time remains: %.2f \n', toc, remain_time);
    fprintf(s);
  
  
  
  % test
    
  % XTest: testing data
    XTest = zeros(41,41,1,length(testData.BW));
    
    for j = 1:length(testData.BW)
        XTest(:,:,1, j) = testData.BW(j).image;
    end



    % predict
    % YTest is predict label
    % TTest is true label
    [YTest,scores] = classify(trainedNet,XTest);
    TTest = categorical(testData.label);

    
    
    
    
    
    %  peformance 
    
    tp = 0;
    fp = 0;
    fn = 0;
    tn = 0;
    

    for j = 1:length(YTest)
        if (TTest(j) == categorical(1)) && (YTest(j) == categorical(1))
            tp = tp + 1;
        elseif (TTest(j) == categorical(1)) && (YTest(j) == categorical(0))
            fn = fn + 1;
        elseif (TTest(j) == categorical(0)) && (YTest(j) == categorical(1))
            fp = fp + 1    ;
        elseif (TTest(j) == categorical(0)) && (YTest(j) == categorical(0))
            tn = tn + 1;
        end 

    end

    precision = tp / (tp + fp);

    recall =  tp / (tp + fn);

    accuracy = (tp + tn) / (tp + tn + fp + fn );


    x = {'CNN', ''; 
        'tp', tp; 'fp', fp; 'fn', fn;
        'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


   r = cell2mat(x(2:7,2));
   disp(r);
  result(:, i) = r;		
  
  
end
                     
output = mean(result,2);
disp(output);

    
   
 






    
    
 
    
