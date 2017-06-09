ada_train_features = cfos_feature_vector;
ada_train_labels = ada_test_labels;

ada_test_features = cfos_feature_vector;
ada_test_labels = cfos_label_vector;


ada_train_labels (ada_train_labels == 0) =  -1;
ada_test_labels (ada_test_labels == 0) =  -1;


[estimateclasstotal,model]=adaboost('train',ada_train_features,ada_train_labels,10);

testclass=adaboost('apply',ada_test_features,model);
%% extract features

counter = 0;
answer = 'y';

cfos_feature_vector = [];
cfos_label_vector = [];
tdt_feature_vector = [];
tdt_label_vector = [];

while answer == 'y'
    counter = counter + 1
%     target = ['cfos', 'tdt'];
    
    [filename,pathname] = uigetfile('../images/new/untitled folder/*.tif', 'Select cfos image file');
    cfos_image_path = [pathname, filename];
    
%     [filename,pathname] = uigetfile('../images/*.tif', 'Select tdt image file');
%     tdt_image_path = [pathname, filename];
    
    [filename,pathname] = uigetfile('../images/new/untitled folder/*.xlsx', 'Select tag file');
    tag_path = [pathname, filename];
    
    [cfos_features, cfos_labels] = extract_feature_and_import_tags(cfos_image_path, tag_path, 'cfos');
    
    cfos_feature_vector = [cfos_feature_vector; cfos_features];
    cfos_label_vector = [cfos_label_vector; cfos_labels];

%     [tdt_features, tdt_labels] = extract_feature(tdt_image_path, tag_path, 'tdt');
%     tdt_feature_vector = [tdt_feature_vector; tdt_features];
%     tdt_label_vector = [tdt_label_vector; tdt_labels];
    
    answer = input('more training images? y or n : ', 's');

end
%% train images 




adaboost_train_feature_vector = cfos_feature_vector;
adaboost_train_label_vector = cfos_label_vector;

adaboost_train_label_vector (adaboost_train_label_vector == 0) =  -1;

[estimateclasstotal,model_adaboost_1] = adaboost('train',adaboost_train_features,adaboost_train_labels,10);
[estimateclasstotal,model_adaboost_2] = adaboost('train',adaboost_train_features,adaboost_train_labels,50);


%% test images

 [filename,pathname] = uigetfile('../images/new/untitled folder/*.tif', 'Select image file');
    cfos_test_image_path = [pathname, filename]

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];

    [filename,pathname] = uigetfile('../images/new/untitled folder/*.xlsx', 'Select tag file');
    test_tag_path = [pathname, filename];

    [cfos_test_feature_vector, cfos_test_label_vector] = extract_feature_and_import_tags(cfos_test_image_path, test_tag_path, 'cfos');
 



    % [tdt_test_feature_vector, tdt_test_label_vector] = extract_feature_and_import_tags(tdt_test_image_path, test_tag_path, 'tdt');


%% test model
    

    adaboost_predict_label_1 = adaboost('apply',cfos_test_feature_vector,model_adaboost_1);
    adaboost_predict_label_2 = adaboost('apply',cfos_test_feature_vector,model_adaboost_2);

    
    adaboost_predict_label_1(adaboost_predict_label_1 == -1) = 0;
    adaboost_predict_label_2(adaboost_predict_label_2 == -1) = 0;

%% accuracy 

tp = 0;
fp = 0;
fn = 0;
tn = 0;


for i = 1:length(adaboost_predict_label_1)
    if (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_1(i) == 1)
        tp = tp + 1;
    elseif (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_1(i) == 0)
        fn = fn + 1;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_1(i) == 1)
        fp = fp + 1    ;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_1(i) == 0)
        tn = tn + 1;
    end 
        
end

precision = tp / (tp + fp);

recall =  tp / (tp + fn);

accuracy = (tp + tn) / (tp + tn + fp + fn );


x = {'model 1', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};

display(x);

tp = 0;
fp = 0;
fn = 0;
tn = 0;
for i = 1:length(adaboost_predict_label_2)
    if (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_2(i) == 1)
        tp = tp + 1;
    elseif (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_2(i) == 0)
        fn = fn + 1;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_2(i) == 1)
        fp = fp + 1    ;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_2(i) == 0)
        tn = tn + 1;
    end 
        
end


precision = tp / (tp + fp);

recall =  tp / (tp + fn);

accuracy = (tp + tn) / (tp + tn + fp + fn );

x = {'model 2', '';
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};

disp(x)

%% plot
cfos_mislabel = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, adaboost_predict_label_1);
cfos_mislabel_2 = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, adaboost_predict_label_2);


%%


