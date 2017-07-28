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



%% load images

% select multiple image and tag files
[filename,pathname] = uigetfile('../images/new/DH/data/cfos/*.tif', ...
    'Select image file', 'MultiSelect', 'on' );
cfos_image_path_vector = strcat(pathname, filename(:)); 


[filename,pathname] = uigetfile('../images/new/DH/data/tags/*.xlsx', ...
    'Select image file', 'MultiSelect' , 'on');
tag_path_vector = strcat(pathname, filename(:));


% extract patches from each image, extract labels
for i = 1: length(cfos_image_path_vector)    
    disp(i);  
    [ ~, ~, ~, labels, BW_patch, ~, Gray2_patch]...                       
        = create_pixel_features(cfos_image_path_vector{i}, tag_path_vector{i}, 'cfos');

    BW_patch_vector = [BW_patch_vector   BW_patch];
    Gray2_patch_vector = [Gray2_patch_vector   Gray2_patch];         
    label_vector = [label_vector;  labels];      

end
    
 %% create data structure

% store all patches and labels in imageData 
imageData = struct('BW', BW_patch_vector, 'Gray', Gray2_patch_vector, ...
    'label', label_vector);  

Q = length(BW_patch_vector); 

% randomize indices 
Ind = randperm(Q);

% set k-fold validation
k = 5;
cv = cvpartition(Q, 'kfold', k);

% % divide into three subsets with random indices      
% [trainInd,testInd] = dividerand(Q,80,20); 



    
%% specify layers

% image input layer
% data augmentation is used to reduce overfitting
inputlayer = imageInputLayer([41, 41, 1] );

% convolutional layer
% filter size and Filters are random
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


% construct layers
layers = [inputlayer
          convlayer
          relulayer
          maxpoollayer
          fullconnectlayer
          smlayer
          coutputlayer];
      




%% learn
result = [];

for i = 1:k
    % divide into two subsets 
    trainInd = find(training(cv,i));
    testInd  = find(test(cv,i));

    trainData = struct('BW', imageData.BW(trainInd(1:end)), 'Gray', ...
      imageData.Gray(trainInd(1:end)), 'label', imageData.label(trainInd(1:end)));                                   

    testData = struct('BW', imageData.BW(testInd(1:end)), 'Gray', ...
      imageData.Gray(testInd(1:end)), 'label', imageData.label(testInd(1:end)));  
  
  
  % create 4-D image array
    X = zeros(41,41,1,length(trainData.BW));
    for j = 1:length(trainData.BW)
        X(:,:,1, j) = trainData.BW(j).image;
    end

    Y = categorical(trainData.label);

    options = trainingOptions('sgdm');
    
    % ouput
    s = sprintf('%d / %d', i,k);
    disp(s)
    
    % train net
    trainedNet = trainNetwork(X, Y,layers,options);


  
  
  
  
  % create test data
    
    XTest = zeros(41,41,1,length(testData.BW));
    
    for j = 1:length(testData.BW)
        XTest(:,:,1, j) = testData.BW(j).image;
    end



    % predict
    % YTest is predict label
    % TTest is true label
    [YTest,scores] = classify(trainedNet,XTest);
    TTest = categorical(testData.label);

    
    
    
    
    
    % calculate peformance 
    
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


    x = {'ANN', ''; 
        'tp', tp; 'fp', fp; 'fn', fn;
        'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


   r = cell2mat(x(2:7,2));

  result = [result, r];

  
  
end
  
                       

  

    
   
 






    
    
 
    
