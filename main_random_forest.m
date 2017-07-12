%% train 

training_features = cfos_feature_vector;
training_labels = cfos_label_vector;


rng(1);
B = TreeBagger(100,training_features,training_labels,'OOBPrediction','On',...
    'Method','classification')

view(Mdl.Trees{1},'Mode','graph')

figure;
oobErrorBaggedEnsemble = oobError(Mdl);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';
%% test images

    [filename,pathname] = uigetfile('../images/new/test/*.tif', 'Select image file');
    cfos_test_image_path = [pathname, filename]

    % [filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
    % tdt_test_image_path = [pathname, filename];

    [filename,pathname] = uigetfile('../images/new/test/*.xlsx', 'Select tag file');
    test_tag_path = [pathname, filename]

    [cfos_test_feature_vector, cfos_test_label_vector] = extract_feature_and_load_tags(cfos_test_image_path, test_tag_path, 'cfos');
 



    % [tdt_test_feature_vector, tdt_test_label_vector] = extract_feature_and_import_tags(tdt_test_image_path, test_tag_path, 'tdt');


    
%% 

RF_predict_labels = predict(B,cfos_test_feature_vector);
RF_predict_labels = str2double(RF_predict_labels);
%% accuracy 

tp = 0;
fp = 0;
fn = 0;
tn = 0;


for i = 1:length(ANN_predict_label)
    if (cfos_test_label_vector(i) == 1) && (RF_predict_labels(i) == 1)
        tp = tp + 1;
    elseif (cfos_test_label_vector(i) == 1) && (RF_predict_labels(i) == 0)
        fn = fn + 1;
    elseif (cfos_test_label_vector(i) == 0) && (RF_predict_labels(i) == 1)
        fp = fp + 1    ;
    elseif (cfos_test_label_vector(i) == 0) && (RF_predict_labels(i) == 0)
        tn = tn + 1;
    end 
        
end

precision = tp / (tp + fp);

recall =  tp / (tp + fn);

accuracy = (tp + tn) / (tp + tn + fp + fn );


x = {'Random Forest', ''; 
    'tp', tp; 'fp', fp; 'fn', fn;
    'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};

display(x);

%% analyze
cfos_mislabel = check_mislabeled(cfos_test_image_path, cfos_test_label_vector, RF_predict_labels);
% % tdt_midlabel = check_mislabeled(tdt_test_image_path, tdt_test_label_vector, tdt_predict_label_L);

