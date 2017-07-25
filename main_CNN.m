%% set default


BW_patch_vector = [];
Gray1_patch_vector = [];
Gray2_patch_vector = [];

label_vector = [];

%% load images
% digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
%         'nndatasets','DigitDataset');
% digitData = imageDatastore(digitDatasetPath, ...
%         'IncludeSubfolders',true,'LabelSource','foldernames');
% CountLabel = digitData.countEachLabel;
% 


%% load images

    [filename,pathname] = uigetfile('../images/new/DH/data/cfos/*.tif', ...
        'Select image file', 'MultiSelect', 'on' );

    cfos_image_path_vector = strcat(pathname, filename(:)); 
    
 
    [filename,pathname] = uigetfile('../images/new/DH/data/tags/*.xlsx', ...
        'Select image file', 'MultiSelect' , 'on');
    tag_path_vector = strcat(pathname, filename(:));
    
    
    
    for i = 1: length(cfos_image_path_vector)    
        disp(i);  
        [ ~, ~, ~, labels, BW_patch, ~, Gray2_patch]...                       
            = create_pixel_features(cfos_image_path_vector{i}, tag_path_vector{i}, 'cfos');

        BW_patch_vector = [BW_patch_vector   BW_patch];
        Gray2_patch_vector = [Gray2_patch_vector   Gray2_patch];         
        label_vector = [label_vector;  labels];      
    
    end
    


%%


imageData = struct('BW', BW_patch_vector, 'Gray', Gray2_patch_vector, ...
    'label', label_vector);  


 Q = length(BW_patch_vector); 

 % divide into three subsets with random indices      
 [trainInd,testInd] = dividerand(Q,80,20);   
                       
 
  trainData = struct('BW', imageData.BW(trainInd(1:end)),  'label', imageData.label(trainInd(1:end)));                                   

  testData = struct('BW', imageData.BW(testInd(1:end)),'label', imageData.label(testInd(1:end)));                

 
%  
%  
%  trainData = struct('BW', imageData.BW(1:1000),  'label', imageData.label(1:1000));                                   
% %  valData = struct('BW', imageData.BW(valInd(1:end)),'label', imageData.label(valInd(1:end)));                                     
%  testData = struct('BW', imageData.BW(1001: 1200),'label', imageData.label(1001:1200));                
% 


    
%% specify layers

% image input layer
% data augmentation is used to reduce overfitting
inputlayer = imageInputLayer([41, 41, 1] );

% convolutional layer
% filter size and Filters are random
convlayer = convolution2dLayer([4,4],7,'Stride',3);

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
X = zeros(41,41,1,length(trainData.BW));
for i = 1:length(trainData.BW)
    X(:,:,1, i) = trainData.BW(i).image;
end


Y = categorical(trainData.label);

options = trainingOptions('sgdm');

trainedNet = trainNetwork(X, Y,layers,options);



    

    
    
%% classify and test
    
XTest = zeros(41,41,1,length(testData.BW));


for i = 1:length(testData.BW)
    XTest(:,:,1, i) = testData.BW(i).image;
end




[YTest,scores] = classify(trainedNet,XTest);


TTest = categorical(testData.label);
    
accuracy = sum(YTest == TTest)/numel(TTest)
   
%% 
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


x = {'ANN', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


a = cell2mat(x(2:7,2));



display(a);

    
    
 hist(testData.label);
 
    
