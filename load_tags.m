function [cfos_labels] = load_tags(tag_path, centroid, target)

% load tag file
% raw takes both numeric and text data in cell array

% file_cat = '/Users/qingdai/Desktop/fos_detection/pictures/tagged data of #20 E3 LDH.xlsx';
[num,txt,raw] = xlsread(tag_path);


tags = [];
for i = 1:size(raw,1)
    if (contains(raw(i,2), target) || contains(raw(i,2), 'colabel'))
        tags = [tags;horzcat(num(i-1,1), num(i-1,3:4))];
    end
end

% load tags, pair tags with candidates
[num_of_positive_signals,positive_signals] = match_tags(tags, centroid);

%%tags-read, centroid-green
figure;
imshow(I_bw);
hold on;
plot(tags(:,2), tags(:,3),'r*');  % manually tag red
    
hold on
plot(candidate_centroid(:,1), candidate_centroid(:,2), 'go')

