%% 

counter = 0;
answer = 'y';

BW_pixel_vector = [];
Gray1_pixel_vector = [];
Gray2_pixel_vector = [];

label_vector = [];

while answer == 'y'
    counter = counter + 1
%     target = ['cfos', 'tdt'];
    
    [filename,pathname] = uigetfile('../images/new/DH/train/*.tif', 'Select image file');
    train_image_path = [pathname, filename];
    disp(filename);

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];


    [filename,pathname] = uigetfile('../images/new/DH/train/*.xlsx', 'Select tag file');
    tag_path = [pathname, filename];
    disp(filename);

    [BW_pixels,Gray1_pixels,Gray2_pixels, labels] = create_pixel_features(train_image_path, tag_path, 'cfos');
    
    BW_pixel_vector = [BW_pixel_vector;  BW_pixels];
    Gray1_pixel_vector = [Gray1_pixel_vector;  Gray1_pixels];
    Gray2_pixel_vector = [Gray2_pixel_vector;  Gray2_pixels];

    label_vector = [label_vector;  labels];
    
    answer = input('more training images? y or n : ', 's');

end



%% test images

    [filename,pathname] = uigetfile('../images/new/DH/test/*.tif', 'Select image file');
    cfos_test_image_path = [pathname, filename]

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];

    [filename,pathname] = uigetfile('../images/new/DH/test/*.xlsx', 'Select tag file');
    test_tag_path = [pathname, filename]

    [test_BW_pixels, test_Gray1_pixels, test_Gray2_pixels, test_labels] = create_pixel_features(cfos_test_image_path, test_tag_path, 'cfos');

    % [tdt_test_feature_vector, tdt_test_label_vector] = extract_feature_and_import_tags(tdt_test_image_path, test_tag_path, 'tdt');



%% NN

inputs = Gray2_pixel_vector';
targets = label_vector';

% Create a Pattern Recognition Network

net=patternnet([784]);


% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 75/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;


% Train the Network
[net,tr] = train(net,inputs,targets);
view(net);

genFunction(net,'myNN', 'MatrixOnly','yes');



% [predict_label] = myNeuralNetworkFunction(test_BW_pixels);
% [predict_label] = myNeuralNetworkFunction(test_Gray1_pixels);
[predict_label] = myNN(test_Gray2_pixels');
predict_label = predict_label';

% [predict_label] = NNfun_gray(test_BW_pixels);

predict_label(predict_label < 0.5) = 0;
predict_label(predict_label >= 0.5) = 1;



%% accuracy 

tp = 0;
fp = 0;
fn = 0;
tn = 0;


for i = 1:length(predict_label)
    if (test_labels(i) == 1) && (predict_label(i) == 1)
        tp = tp + 1;
    elseif (test_labels(i) == 1) && (predict_label(i) == 0)
        fn = fn + 1;
    elseif (test_labels(i) == 0) && (predict_label(i) == 1)
        fp = fp + 1    ;
    elseif (test_labels(i) == 0) && (predict_label(i) == 0)
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

%% analyze
cfos_mislabel = check_mislabeled(cfos_test_image_path, test_labels, predict_label);
% % tdt_midlabel = check_mislabeled(tdt_test_image_path, tdt_test_label_vector, tdt_predict_label_L);

