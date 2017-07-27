%% read images
% try regexp, dir, abcFiles = dir('*abc*.mat');

cfos_location = '../images/new/DH/data/cfos'; 


%load images
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
 
%% load images
[filename,pathname] = uigetfile('../images/new/DH/data/cfos/*.tif',...
    'Select image file','MultiSelect' , 'on');

cfos_image_path_vector = strcat(pathname, filename(:));
    
    
%     [filename,pathname] = uigetfile('../images/new/DH/data/tdt/*.tif', 'Select image file', ...
%         'MultiSelect' , 'on');
%     tdt_image_path_vector = strcat(pathname, filename(:));
%     
 
%% load tags
[filename,pathname] = uigetfile('../images/new/DH/data/tags/*.xlsx',...
    'Select image file','MultiSelect' , 'on');
tag_path_vector = strcat(pathname, filename(:));

%% extract patches and labels
 
for i = 1: length(cfos_image_path_vector)
    disp(i);
    [ ~, ~, ~, labels, BW_patch, ~, Gray2_patch]...
        = create_pixel_features(cfos_image_path_vector{i}, tag_path_vector{i}, 'cfos');
    
    % contatenate patch arrays and label arrays

    BW_patch_vector = [BW_patch_vector   BW_patch];

%     Gray1_patch_vector = [Gray1_patch_vector  Gray1_patch];
    
    Gray2_patch_vector = [Gray2_patch_vector   Gray2_patch];
    
    label_vector = [label_vector;  labels];
    
end
        
  
%% create imageData structure to store patches and labels
imageData = struct('BW', BW_patch_vector, 'Gray', Gray2_patch_vector, ...
    'label', label_vector);
    
Q = length(BW_patch_vector);






% divide into three subsets with random indices
[trainInd,valInd,testInd] = dividerand(Q,70,15,15);
     
    

trainData = struct('BW', imageData.BW(trainInd(1:end)), 'Gray', imageData.Gray(trainInd(1:end)),...
    'label', imageData.label(trainInd(1:end)));
valData = struct('BW', imageData.BW(valInd(1:end)), 'Gray', imageData.Gray(valInd(1:end)),...
    'label', imageData.label(valInd(1:end)));
testData = struct('BW', imageData.BW(testInd(1:end)), 'Gray', imageData.Gray(testInd(1:end)),...
    'label', imageData.label(testInd(1:end)));   
    
    



%% specify layers

% image input layer
% data augmentation is used to reduce overfitting
inputlayer = imageInputLayer([41, 41, 1] );

% convolutional layer
% filter size and Filters are random

%number of filter more
% stride less
convlayer = convolution2dLayer([4,4],7,'Stride',4);

% RELU layer
relulayer = reluLayer();

% pooling layer
maxpoollayer = maxPooling2dLayer([2,2], 'Stride', 1);
% avgpoollayer = averagePooling2dLayer([2,2], 'Stride', 1);

% dropout layer

% fully conncected layer, 2 classes
fullconnectlayer = fullyConnectedLayer(2);

% softmax layer
smlayer = softmaxLayer();

% classification layer
coutputlayer = classificationLayer();


%% construct layers
layers = [inputlayer
          convlayer
          relulayer
          maxpoollayer
          fullconnectlayer
          smlayer
          coutputlayer];
      
%% train
% create an 4D array (height * width * channels * image_index) as traning
% data
X = zeros(41,41,1,length(trainData.Gray));

for i = 1:length(length(trainData.label))
    X(:,:,1, i) = trainData.Gray(i).image;
end

% create a categorical array as traning labels
Y = categorical(trainData.label);

% options set to stochastic gradient descent with momentum
options = trainingOptions('sgdm');

trainedNet = trainNetwork(X, Y,layers,options);


%% validate
% create 4-D array to validate
XVal = zeros(41,41,1,length(valData.label));
for i = 1:length(valData.label)
    XVal(:,:,1, i) = valData.Gray(i).image;
end

% create a categorical array as validation labels
TVal = categorical(valData.label);

[YVal,scoreVal] = classify(trainedNet,XVal);


%% test

% create a 4D array as tetsing data
XTest = zeros(41,41,1,length(testData.label));

for i = 1:length(testData.label)
    XTest(:,:,1, i) = testData.Gray(i).image;
end

% create a categorical array as testing label
TTest = categorical(testData.label);

% predict 
[YTest,scores] = classify(trainedNet,XTest);
predict_label = double(YTest) -1;
 
%% accuracy 

tp = 0;
fp = 0;
fn = 0;
tn = 0;


for i = 1:length(YTest)
    if (TTest(i) == categorical(1)) && (YTest(i) == categorical(1))
        tp = tp + 1;
    elseif (TTest(i) == categorical(1)) && (YTest(i) == categorical(0))
        fn = fn + 1;
    elseif (TTest(i) == categorical(0)) && (YTest(i) == categorical(1))
        fp = fp + 1    ;
    elseif (TTest(i) == categorical(0)) && (YTest(i) == categorical(0))
        tn = tn + 1;
    end 
        
end

precision = tp / (tp + fp);

recall =  tp / (tp + fn);

accuracy = (tp + tn) / (tp + tn + fp + fn );


x = {'CNN', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


a = cell2mat(x(2:7,2));



display(a);

    
    
%% analyze
cfos_mislabel = check_mislabeled(cfos_test_image_path, test_labels, predict_label);
% % tdt_midlabel = check_mislabeled(tdt_test_image_path, tdt_test_label_vector, tdt_predict_label_L);
   
    
