classNames = {'Apple', 'Banana', 'Broccoli', 'Cookie', 'Egg', 'FrenchFries', 'Hotdog', 'Rice', 'Strawberry', 'Tomato'};

% How many bins for the HSV values do we want.
numberOfLevelsForH = 12;
numberOfLevelsForS = 3;
numberOfLevelsForV = 3;

Color_Model = struct('ClassName', {}, 'Data', {});

for class = 1:length(classNames)
    strcat('Seg_Images/', classNames{class},'/*.jpg')
    fileNames = dir(strcat('Seg_Images/', classNames{class},'/*.jpg'));
    
    Data = zeros(length(fileNames),numberOfLevelsForH*numberOfLevelsForS*numberOfLevelsForV);
    for fileIdx = 1:size(fileNames)
        fileName = strcat('Seg_Images/', classNames{class},'/',fileNames(fileIdx).name)
        rgbImage = imread(fileName);
        %Resize the image if it's too large
        if max(size(rgbImage))>1000
            ratio = max(size(rgbImage))/1000;
            rgbImage = imresize(rgbImage,1/ratio); 
        end
        Data(fileIdx, :) = hsvHistogram(rgbImage, numberOfLevelsForH,numberOfLevelsForS, numberOfLevelsForV);
    end
    % Renames the model to save
    Color_Model(end+1) = struct('ClassName', {classNames{class}}, 'Data', {Data});
end
save('Seg_Images/Z_hist_model/Color_Model.mat', 'Color_Model');