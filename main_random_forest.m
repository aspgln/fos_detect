%%  import images and extract features

Feature_vector = [];
Label_vector = [];



% select multiple image and tag files
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
    
    s = sprintf(' %d / %d \n time used: %.2f \n time remains %.2f \n', i,l, toc, remain_time);   
    fprintf(s);   
    
     [Features, Labels] = extract_feature_and_import_tags...
         (cfos_image_path_vector{i}, tag_path_vector{i}, 'cfos');
    
    
    
    Feature_vector = [Feature_vector; Features];
    Label_vector = [Label_vector;  Labels];      
    
end


%% set indices and cross validation


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

%% train and test 

result = zeros(6,k);

for i = 1:k
    
    disp(i)
    
    % divide into two subsets
    trainInd = total_index(training(cv,i));
    testInd  = total_index(test(cv,i));
    
    trainFeatures = Feature_vector(trainInd(1:end), :);
    trainLabels = Label_vector(trainInd(1:end), :);
    
    testFeatures = Feature_vector(testInd(1:end), :);
    testLabels = Label_vector(testInd(1:end), :);
    
    % train
    
    % random number generation
    rng(1);
    
    B = TreeBagger(100,trainFeatures,trainLabels,'OOBPrediction',...
        'On', 'Method','classification');
    
%     view(B.Trees{1},'Mode','graph')
%     view(B.Trees{1})

%     figure;
%     oobErrorBaggedEnsemble = oobError(B);
%     plot(oobErrorBaggedEnsemble)
%     xlabel 'Number of grown trees';
%     ylabel 'Out-of-bag classification error';
%     
    % predict
    RF_predict_labels = predict(B,testFeatures);
    RF_predict_labels = str2double(RF_predict_labels);
    
    % accuracy
    tp = 0;
    fp = 0;
    fn = 0;
    tn = 0;


    for j = 1:length(RF_predict_labels)
        if (testLabels(j) == 1) && (RF_predict_labels(j) == 1)
            tp = tp + 1;
        elseif (testLabels(j) == 1) && (RF_predict_labels(j) == 0)
            fn = fn + 1;
        elseif (testLabels(j) == 0) && (RF_predict_labels(j) == 1)
            fp = fp + 1    ;
        elseif (testLabels(j) == 0) && (RF_predict_labels(j) == 0)
            tn = tn + 1;
        end 

    end

    precision = tp / (tp + fp);

    recall =  tp / (tp + fn);

    accuracy = (tp + tn) / (tp + tn + fp + fn );


    x = {'Random Forest', ''; 
        'tp', tp; 'fp', fp; 'fn', fn;
        'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};
    
    r = cell2mat(x(2:7,2));
    disp(r);
    result(:, i) = r;			
end

disp('avg:');
output = mean(result,2);
disp(output);





%% analyze
cfos_mislabel = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, RF_predict_labels);
% % tdt_midlabel = check_mislabeled(tdt_test_image_path, tdt_test_label_vector, tdt_predict_label_L);

