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
% input has to be patches, not pixels
counter = 0;
num_of_image = 9;

while counter ~= num_of_image
    counter = counter + 1;
    disp(counter);
%     target = ['cfos', 'tdt'];
    
    [filename,pathname] = uigetfile('../images/new/DH/train/*.tif', 'Select image file');
    train_image_path = [pathname, filename];
    disp(filename);

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];


    [filename,pathname] = uigetfile('../images/new/DH/train/*.xlsx', 'Select tag file');
    tag_path = [pathname, filename];
    disp(filename);

    [BW_pixels,Gray1_pixels,Gray2_pixels, labels, BW_patch, Gray1_patch, Gray2_patch]...
            = create_pixel_features(train_image_path, tag_path, 'cfos');
    
    BW_patch_vector = [BW_patch_vector   BW_patch];
    Gray1_patch_vector = [Gray1_patch_vector   Gray1_patch];
    Gray2_patch_vector = [Gray2_patch_vector   Gray2_patch];
    
    label_vector = [label_vector;  labels];
    
%     answer = input('more training images? y or n : ', 's');

end
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


%% construct layers
layers = [inputlayer
          convlayer
          relulayer
          maxpoollayer
          fullconnectlayer
          smlayer
          coutputlayer];
      
%% train
X = zeros(41,41,1,length(BW_patch_vector));
for i = 1:length(BW_patch_vector)
    X(:,:,1, i) = BW_patch_vector(i).image;
end
a = BW_patch_vector(1).image;


Y = categorical(label_vector);

options = trainingOptions('sgdm');

trainedNet = trainNetwork(X, Y,layers,options);


%% test 
[filename,pathname] = uigetfile('../images/new/DH/test/*.tif', 'Select image file');
    cfos_test_image_path = [pathname, filename]

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];

    [filename,pathname] = uigetfile('../images/new/DH/test/*.xlsx', 'Select tag file');
    test_tag_path = [pathname, filename]

    [test_BW_pixels, test_Gray1_pixels, test_Gray2_pixels, test_labels, test_BW_patch, test_Gray1_patch, test_Gray2_patch] = ...
        create_pixel_features(cfos_test_image_path, test_tag_path, 'cfos');

%% classify and test
    
XTest = zeros(41,41,1,length(test_BW_patch));


for i = 1:length(test_BW_patch)
    XTest(:,:,1, i) = test_BW_patch(i).image;
end


a = test_BW_patch(1).image;


[YTest,scores] = classify(trainedNet,XTest);


TTest = categorical(test_labels);
    
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

    
    
    
    
