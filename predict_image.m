%% select model

[filename,pathname] = uigetfile('../model/*.mat', ...
   'Select model' );
modelPath = [pathname, filename];
a = load(modelPath, 'Model');
model = a.Model;


%% select test image

[filename,pathname] = uigetfile('../data/DH/cfos/*.tif', ...
   'Select image file', 'MultiSelect', 'on' );
test_image_path_vector = strcat(pathname, filename(:)); 

l = length(filename);

test_Feature_vector = []

for i = 1: l  
    % need 2 versions
    [test_Features, Labels] = extract_feature_and_import_tags...
         (test_image_path_vector{i}, tag_path_vector{i}, 'cfos');
    
    test_Feature_vector = [test_Feature_vector; test_Features];
    
    % predict 
    test_RF_predict_labels = predict(model,test_Feature_vector);
    test_RF_predict_labels = str2double(test_RF_predict_labels);
    
    
    visualize_test_image(test_image_path_vector{i}, test_RF_predict_labels);

end
