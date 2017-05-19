
test_model = cfos_model_linear;
test_model_2 = cfos_model;
[filename,pathname] = uigetfile('../images/*.tif', 'Select image file');
test_image_path = [pathname, filename];

[test_feature_vector, num_of_candidates] = extract_feature(test_image_path);
test_label_vector = zeros(num_of_candidates,1);

[test_predict_label_L] = svmpredict(test_label_vector, test_feature_vector, test_model, ' -b 1');

[test_predict_label] = svmpredict(test_label_vector, test_feature_vector, test_model_2);

 visualize_test_image(test_image_path, test_predict_label_L);
 visualize_test_image(test_image_path, test_predict_label);
