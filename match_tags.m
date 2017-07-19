function [num_of_positive_signals,positive_signals] = match_tags(load_tags, Candidate_properties)



%compared centroid and tags in two different colors
num_of_positive_signals = length(load_tags);

centroids = {Candidate_properties.Centroid};

positive_signals = [];

% pair tag and signals with minimum euclidean norm



all_norms = zeros(num_of_positive_signals, 1);


for i = 1:length(load_tags)
    eu_norm = zeros(length(centroids),1);

    for j = 1:length(centroids)
        eu_norm(j) = norm(load_tags(i,2:3) -centroids{j});
    end
    
    [min_norm,index] = min(eu_norm);
%     all_norms(i) =  min_norm;

    positive_signal = [index, centroids{index}];
    positive_signals = cat(1,positive_signals, positive_signal);  
end


