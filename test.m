% read tag number, X, Y
excel = xlsread('tagged data of #20 E3 LDH copy.xlsx','A15:D37');

%convert coordinate
excel(:,4) = 1200 - excel(:,4);

% look for positive signals
centroid = [Region.Centroid];
centroid = [centroid(1:2:245);centroid(2:2:246)]';
centroid = sortrows(centroid,1);
%%
positive_signal = [];

for i = 1:length(excel)
%     
        [row, col] = find(((centroid(:,1) > excel(i,3) - 80) & (centroid(:,1) < excel(i,3) + 80)))
        [row2, col2] = find(((centroid(:,2) > excel(i,4) - 80) & (centroid(:,2) < excel(i,4) + 80)))
        
        if row == row2 & col == col2 
          
          if ~isempty(row) && ~isempty(col)
            positive_signal = cat(1,positive_signal, [row,col]);
          end
        end
end
%%


for i = 1 %:length(excel)
%     
        row = find(((centroid(:,1) > excel(i,3) - 80) & (centroid(:,1) < excel(i,3) + 80)))
        row2 = find(((centroid(:,2) > excel(i,4) - 80) & (centroid(:,2) < excel(i,4) + 80)))
end






        
        