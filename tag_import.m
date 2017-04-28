function [num_of_positive_signals,positive_signals_index] = tag_import(file_cat, candidate_centroid)

% raw takes both numeric and text data in cell array

[num,txt,raw] = xlsread(file_cat);


import_tags = [];
for i = 1:size(raw,1)
    if (contains(raw(i,2), 'Cfos') || contains(raw(i,2), 'Colabel'))
        import_tags = [import_tags;horzcat(num(i-1,1), num(i-1,3:4))];
    end
end


%compared centroid and tags in two different colors
num_of_positive_signals = length(import_tags);



positive_signals_index = [];

% pair tag and signals with minimun euclidean norm



all_norms = zeros(num_of_positive_signals, 1);


for i = 1:length(import_tags)
    eu_norm = zeros(length(candidate_centroid),1);

    for j = 1:length(candidate_centroid)
        eu_norm(j) = norm(import_tags(i,2:3) -candidate_centroid(j,:));
    end
    
    [min_norm,index] = min(eu_norm);
    all_norms(i) =  min_norm;
    positive_signals_index = cat(1,positive_signals_index, index);  %index in Candidate_centroid
end