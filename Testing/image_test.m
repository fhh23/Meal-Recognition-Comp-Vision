path_to_images = 'imaged_tryout/';

load('Seg_Images/Z_hist_model/Color_Model.mat');

numberOfLevelsForH = 12;
numberOfLevelsForS = 3;
numberOfLevelsForV = 3; 
fileNames = dir(strcat('imaged_tryout/*.jpg'));
minval = zeros(length(fileNames), size(Color_Model, 2));

countCor = 0;
countWrong = 0;

fileName = 'hot71.jpg';
    
rgbImage = imread(strcat(path_to_images, fileName));
%Resize the image if it's too large
if max(size(rgbImage))>1000
    ratio = max(size(rgbImage))/1000;
    rgbImage = imresize(rgbImage,1/ratio); 
end
nColors = 3;
while 1
    try
        BB = seg_kmeans( rgbImage, nColors );
        break;
    catch ex
        nColors = nColors -1;
    end
end
scores = zeros(nColors, 10);
for regionIdx = 1:nColors
    imgRegion = rgbImage(BB(regionIdx,1):BB(regionIdx,2), BB(regionIdx,3):BB(regionIdx,4), :);
    imgHist = hsvHistogram(imgRegion, numberOfLevelsForH,numberOfLevelsForS, numberOfLevelsForV);

    [classId, scores(regionIdx, :)] = calcMandist(imgHist, Color_Model);
end

mergedScores = min(scores(1, :), scores(2, :));
[dist, classDecision] = min(mergedScores);

[tok, rem] = strtok(rem);
output = [fileName ': actual:' tok '  guess:' lower(Color_Model(classDecision).ClassName)]

if strcmp(tok, lower(Color_Model(classDecision).ClassName))
    countCor = countCor + 1;
else
    countWrong = countWrong + 1;
end

fprintf(fileID, '%s %s correct;%s\n', fileName, lower(Color_Model(classDecision).ClassName), tok);
tLine = fgetl(labelFile);