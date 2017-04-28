[filename,pathname,filterindex] = uigetfile('../*.tif', 'Select image file');
image_path = strcat(pathname,filename);

[filename,pathname,filterindex] = uigetfile('../*.xlsx', 'Select tag file');
tag_path = strcat(pathname,filename);

