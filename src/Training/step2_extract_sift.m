function [siftModels,success] = step2_extract_sift(d_path_gray,classes)

s_path = d_path_gray;
siftModels={};

for class = 1:length(classes)
    className = cell2mat(classes(class));
    fileNames = dir(strcat(s_path,className));
    
    data = [];
    for i = 3:size(fileNames,1)
        fileNames(i).name
        [im,desc,locs] = sift(strcat(s_path,className,fileNames(i).name));
        [idx C] = kmeans(desc,10); % learn 10 clusters from each image 
        data = [data; C];
    end
    
    siftModels = [siftModels; data];
end
success=1;        