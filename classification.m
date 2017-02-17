% read tag number, X, Y
% [filename,pathname,filterindex] = uigetfile('*.xlsx', 'Select excel file');
% file_cat = strcat(pathname,filename); 
[num,txt,raw] = xlsread('/Users/qingdai/Desktop/fos_detection/pictures/tagged data of #20 E3 LDH.xlsx');


import_tags = [];
for i = 1:size(raw,1)
    if (contains(raw(i,2), 'Cfos') || contains(raw(i,2), 'Colabel'))
        import_tags = [import_tags;horzcat(num(i-1,1), num(i-1,3:4))];
    end
end
%compared centroid and tags in two diference colors

num_of_positive_signals = length(import_tags);

%%
% look for positive signals
centroid = [Region.Centroid];           %struct to linear indices
centroid = [centroid(1:2:end);centroid(2:2:end)]';     %convert to table
%centroid = sortrows(centroid,1);

%%
positive_signals_index = [];

% pair tag and signals with minimun euclidean norm

all_norms = zeros(num_of_positive_signals, 1);


for i = 1:length(import_tags)
    eu_norm = zeros(length(centroid),1);

    for j = 1:length(centroid)
        eu_norm(j) = norm(import_tags(i,2:3) -centroid(j,:));
    end
    
    [min_norm,index] = min(eu_norm);
    all_norms(i) =  min_norm;
    positive_signals_index = cat(1,positive_signals_index, index);  %index is the index in centroid table
end

%%tags-read, centroid-green
figure;
imshow(I_bw);
hold on;
for i = 1:length(import_tags)
    plot(import_tags(i,2), import_tags(i,3),'r*');  % manually tag red
    
end

for i = 1:length(positive_signals_index)
    plot(centroid(positive_signals_index(i),1),  centroid(positive_signals_index(i),2), 'gx');
end


% hold on
% plot(147.1731,810.5705,'r*')
%%
figure;
imshow(BW_patch_reorient(4).image);





%%

for i = 1:num_of_positive_signals
    pos_in_centroid = positive_signals_index(i,1);
    Feature_vector(pos_in_centroid, num_of_features + 1) = 1;
    figure; 
    imshow(BW_patch_reorient(i).image);
    
end


  
        