%classNames = {'Apple', 'Banana', 'Broccoli', 'Cookie', 'Egg', 'FrenchFries', 'Hotdog', 'Rice', 'Strawberry', 'Tomato'};
classNames = {'Apple', 'Banana', 'Broccoli','Egg', 'Rice', 'Strawberry', 'Tomato'};

% How many bins for the HSV values do we want.
numberOfLevelsForH = 36;
numberOfLevelsForS = 36;
numberOfLevelsForV = 36;

Color_Model = struct('ClassName', {}, 'numModels', {} ,'hHist', {}, ...
                     'sHist', {}, 'vHist', {});

for class = 1:length(classNames)
    strcat('new_images/', classNames{class},'/*.jpg')
    fileNames = dir(strcat('new_images/', classNames{class},'/*.jpg'));
    
    hHist = zeros(length(fileNames), numberOfLevelsForH);
    sHist = zeros(length(fileNames), numberOfLevelsForS);
    vHist = zeros(length(fileNames), numberOfLevelsForV);
    for fileIdx = 1:size(fileNames)
        fileName = strcat('new_images/', classNames{class},'/',fileNames(fileIdx).name)
        rgbImage = imread(fileName);
        %Resize the image if it's too large
        if max(size(rgbImage))>1000
            ratio = max(size(rgbImage))/1000;
            rgbImage = imresize(rgbImage,1/ratio); 
        end
        
        nColors = 2;
        while 1
            if nColors == 1
               BB = [ 1, size(rgbImage, 1), 1, size(rgbImage, 2)]; 
               break;
            end
            try
                [BB, labels] = seg_kmeans( rgbImage, nColors );
                break;
            catch ex
                nColors = nColors -1;
            end
        end

        currRatio = 1.0;
        for regionIdx = 1:nColors
            ratio = ((BB(regionIdx,2) - BB(regionIdx,1)+1) * (BB(regionIdx,4) - BB(regionIdx,3) + 1))/(size(rgbImage,1) *size(rgbImage,2));
            if  ratio <= currRatio
                segImage = rgbImage;
                currRatio = ratio;
                if nColors > 1
                    new_labels = repmat(labels(regionIdx, :, :),[1 1 3]);
                    segImage(new_labels == 0) = 0;
                end

                imgRegion = segImage(BB(regionIdx,1):BB(regionIdx,2), BB(regionIdx,3):BB(regionIdx,4), :);
            end
        end
        
        [hHist(fileIdx, :), sHist(fileIdx, :), vHist(fileIdx, :)] = ...
                    hsvHistogram(segImage, numberOfLevelsForH,numberOfLevelsForS, numberOfLevelsForV);
    end
    % Renames the model to save
    Color_Model(end+1) = struct('ClassName', {classNames{class}}, 'numModels', {fileIdx},  ...
                                'hHist', {hHist}, 'sHist', {sHist}, 'vHist', {vHist});
end
save('new_images/Z_hist_model/Color_Model.mat', 'Color_Model');