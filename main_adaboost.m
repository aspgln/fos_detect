%% extract features

counter = 0;
answer = 'y';

cfos_feature_vector = [];
cfos_label_vector = [];
tdt_feature_vector = [];
tdt_label_vector = [];

while answer == 'y'
    counter = counter + 1;
    disp(counter)
%     target = ['cfos', 'tdt'];
    
    [filename,pathname] = uigetfile('../images/new/train/*.tif', 'Select cfos image file');
    cfos_image_path = [pathname, filename];
    disp(filename)
    
%     [filename,pathname] = uigetfile('../images/*.tif', 'Select tdt image file');
%     tdt_image_path = [pathname, filename];
    
    [filename,pathname] = uigetfile('../images/new/train/*.xlsx', 'Select tag file');
    tag_path = [pathname, filename];
    disp(filename)
    
    [cfos_features, cfos_labels] = extract_feature_and_import_tags(cfos_image_path, tag_path, 'cfos');
    
    cfos_feature_vector = [cfos_feature_vector; cfos_features];
    cfos_label_vector = [cfos_label_vector; cfos_labels];

%     [tdt_features, tdt_labels] = extract_feature(tdt_image_path, tag_path, 'tdt');
%     tdt_feature_vector = [tdt_feature_vector; tdt_features];
%     tdt_label_vector = [tdt_label_vector; tdt_labels];
    
    answer = input('more training images? y or n : ', 's');

end
%% train images 




adaboost_train_features = cfos_feature_vector;
adaboost_train_labels = cfos_label_vector;

adaboost_train_labels (adaboost_train_labels == 0) =  -1;
1
[estimateclasstotal,model_adaboost_1] = adaboost('train',adaboost_train_features,adaboost_train_labels,10);
2
[estimateclasstotal,model_adaboost_2] = adaboost('train',adaboost_train_features,adaboost_train_labels,20);
3
[estimateclasstotal,model_adaboost_3] = adaboost('train',adaboost_train_features,adaboost_train_labels,30);
4
[estimateclasstotal,model_adaboost_4] = adaboost('train',adaboost_train_features,adaboost_train_labels,50);
5
[estimateclasstotal,model_adaboost_5] = adaboost('train',adaboost_train_features,adaboost_train_labels,100);


%% test images

 [filename,pathname] = uigetfile('../images/new/test/*.tif', 'Select image file');
    cfos_test_image_path = [pathname, filename]

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];

    [filename,pathname] = uigetfile('../images/new/test/*.xlsx', 'Select tag file');
    test_tag_path = [pathname, filename];

    [cfos_test_feature_vector, cfos_test_label_vector] = extract_feature_and_import_tags(cfos_test_image_path, test_tag_path, 'cfos');
 



    % [tdt_test_feature_vector, tdt_test_label_vector] = extract_feature_and_import_tags(tdt_test_image_path, test_tag_path, 'tdt');


%% test model
    

    adaboost_predict_label_1 = adaboost('apply',cfos_test_feature_vector,model_adaboost_1);
    adaboost_predict_label_2 = adaboost('apply',cfos_test_feature_vector,model_adaboost_2);
    adaboost_predict_label_3 = adaboost('apply',cfos_test_feature_vector,model_adaboost_3);
    adaboost_predict_label_4 = adaboost('apply',cfos_test_feature_vector,model_adaboost_4);
    adaboost_predict_label_5 = adaboost('apply',cfos_test_feature_vector,model_adaboost_5);

    
    adaboost_predict_label_1(adaboost_predict_label_1 == -1) = 0;
    adaboost_predict_label_2(adaboost_predict_label_2 == -1) = 0;
    adaboost_predict_label_3(adaboost_predict_label_3 == -1) = 0;
    adaboost_predict_label_4(adaboost_predict_label_4 == -1) = 0;
    adaboost_predict_label_5(adaboost_predict_label_5 == -1) = 0;
    

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


x = {'model 2', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};

display(x);



tp = 0;
fp = 0;
fn = 0;
tn = 0;


for i = 1:length(adaboost_predict_label_3)
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


x = {'model 3', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};

display(x);



tp = 0;
fp = 0;
fn = 0;
tn = 0;


for i = 1:length(adaboost_predict_label_4)
    if (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_4(i) == 1)
        tp = tp + 1;
    elseif (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_4(i) == 0)
        fn = fn + 1;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_4(i) == 1)
        fp = fp + 1    ;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_4(i) == 0)
        tn = tn + 1;
    end 
        
end

precision = tp / (tp + fp);

recall =  tp / (tp + fn);

accuracy = (tp + tn) / (tp + tn + fp + fn );


x = {'model 4', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};

display(x);






tp = 0;
fp = 0;
fn = 0;
tn = 0;


for i = 1:length(adaboost_predict_label_5)
    if (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_5(i) == 1)
        tp = tp + 1;
    elseif (cfos_test_label_vector(i) == 1) && (adaboost_predict_label_5(i) == 0)
        fn = fn + 1;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_5(i) == 1)
        fp = fp + 1    ;
    elseif (cfos_test_label_vector(i) == 0) && (adaboost_predict_label_5(i) == 0)
        tn = tn + 1;
    end 
        
end

precision = tp / (tp + fp);

recall =  tp / (tp + fn);

accuracy = (tp + tn) / (tp + tn + fp + fn );


x = {'model 5', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};

display(x);
%% plot
cfos_mislabel = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, adaboost_predict_label_1);
cfos_mislabel_2 = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, adaboost_predict_label_2);
cfos_mislabel_3 = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, adaboost_predict_label_3);
cfos_mislabel_4 = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, adaboost_predict_label_4);
cfos_mislabel_5 = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, adaboost_predict_label_5);


%%


