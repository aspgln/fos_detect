%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Creates a patch around centroid of candidate fos target
%
%              Bau Pham 07/2016
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Output is windows = [left right up down]
%There is a tricky part when creating the window after getting the
%coordinates of the path. the rows and columns are inversed when making a
%patch. For example if the centroid is (86, 266) the result is [46 126 226
%306] but when you open the image it will be I(226:306, 46:126)

function windows = create_patch(I, x, y, patch_size)

[num_row, num_column] = size(I);

%round the centroid
x = round(x);
y = round(y);

%if patch size is odd
shift1 = ceil(patch_size/2);
shift2 = floor(patch_size/2);

%left and right shift

if max(1,x-shift1)== 1       %% if border is on the left
    left = 1;
    right = patch_size + 1;
elseif min(num_column, x + shift2) == num_column 
    right = num_column;      %% if border is on the right
    left = num_column - patch_size;
else 
    left = x - shift1;
    right = x+shift2;
end

%up and down

if max(1,y-shift1)== 1       %% if border is on the top
    up = 1;
    down = patch_size + 1;
elseif min(num_row, y + shift2) == num_row 
    down = num_row;      %% if border is on the bottom
    up = num_row - patch_size;
else 
    up = y - shift1;
    down = y +shift2;
end

windows = I(up:down,left:right);

end