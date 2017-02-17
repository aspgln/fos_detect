%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Calculates texture features using the patches of the gray scale image 
%
%              Bau Pham 07/2016
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Texture_Features = Compute_MR8(Gray_image, num_histogram_bins)

%Get MR8 filter bank and features. This returns an 8 x m matrix where m is
%related to pixel size of window. 
I_texture = MR8fast_mex(Gray_image);

%Get max and min values along each dimension (in this case 8); used to make 
%equally sized and spaced histograms

max_texture = max(I_texture, [],2);
min_texture = min(I_texture, [],2);

%Define histogram bins for each of the 8 responses

texture_bins = zeros(num_histogram_bins+1,8);
for i = 1:8
    texture_bins(:,i) = min_texture(i): (max_texture(i)-min_texture(i))/num_histogram_bins: max_texture(i);
end

%Computing the histogram counts and normalizing. Using histcounts and not
%histogram() because I don't want the plots or graphs.

for i = 1:8
    [histo_c(i,:)] = histcounts(I_texture(i,:),texture_bins(:,i),'normalization','probability');
end
    
Texture_Features = histo_c;
end


