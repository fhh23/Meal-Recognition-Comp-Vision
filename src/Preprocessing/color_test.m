path_to_images = 'imaged_tryout/';

load('Seg_Images/Z_hist_model/Color_Model.mat');

numberOfLevelsForH = 12;
numberOfLevelsForS = 3;
numberOfLevelsForV = 3; 

fileID = fopen('colorResults.txt','w');
labelFile = fopen(strcat(path_to_images, 'label.txt'),'r');

fileNames = dir(strcat('imaged_tryout/*.jpg'));
minval = zeros(length(fileNames), size(Color_Model, 2));

tLine = fgetl(labelFile);

countCor = 0;
countWrong = 0;

while ischar(tLine)
    [fileName, rem] = strtok(tLine, ' ');
    
    if ~strcmp(fileName(end-3:end), '.jpg')
        fileName = strcat(fileName, '.jpg');
    end
    rgbImage = imread(strcat(path_to_images, fileName));
    %Resize the image if it's too large
    if max(size(rgbImage))>1000
        ratio = max(size(rgbImage))/1000;
        rgbImage = imresize(rgbImage,1/ratio); 
    end
    nColors = 2;
    while 1
        try
            BB = seg_kmeans( rgbImage, nColors );
            break;
        catch ex
            nColors = nColors -1;
        end
    end
    scores = zeros(nColors, 10);
    testerscores = zeros(nColors, 10);
    for regionIdx = 1:nColors
        imgRegion = rgbImage(BB(regionIdx,1):BB(regionIdx,2), BB(regionIdx,3):BB(regionIdx,4), :);
        imgHist = hsvHistogram(imgRegion, numberOfLevelsForH,numberOfLevelsForS, numberOfLevelsForV);
        ratio = ((BB(regionIdx,2) - BB(regionIdx,1)) * (BB(regionIdx,4) - BB(regionIdx,3)))/(size(rgbImage,1) *size(rgbImage,2));
        [classId, scores(regionIdx, :)] = calcMandist(imgHist, Color_Model);
        testerscores(regionIdx, :) = scores(regionIdx,:) * ratio;
    end
    
    mergedScores = scores(1, :);
    for i=2:nColors
        mergedScores = min(mergedScores, scores(i, :));
    end
    %[dist, classDecision] = min(mergedScores);
    
    % FARHAN CODE
    [im,desc,locs] = test_sift(imgRegion);
    nclusters = 25;
    while 1
    try
        [idx C] = kmeans(desc,nclusters); % learn 10 clusters from each image 
        break;
    catch ex
        nclusters = nclusters -1;
    end
end
    %[idx C] = kmeans(desc,nclusters); % learn 10 clusters from each image 
    testSiftModel = [C];
    [B, I] = sort(mergedScores);
    I
    siftscores = [0];
    for i=1:4
        G = svmclassify(SVMmodels{I(i),1},testSiftModel);
        siftscores(i) = sum(G);
    end
    [dist, classDec] = max(siftscores);
    siftscores
    classDecision = I(classDec);
    classDecision
    %FARHAN CODE -- END
    
    [tok, rem] = strtok(rem);
    output = [fileName ': actual:' tok '  guess:' lower(Color_Model(classDecision).ClassName)]
    
    if strcmp(tok, lower(Color_Model(classDecision).ClassName))
        countCor = countCor + 1;
        fprintf(fileID, '%s %s correct;%s\n', fileName, lower(Color_Model(classDecision).ClassName), tok);
    else
        countWrong = countWrong + 1;
        fprintf(fileID, '%s %s wrong;%s\n', fileName, lower(Color_Model(classDecision).ClassName), tok);
    end
    
    %fprintf(fileID, '%s %s correct;%s\n', fileName, lower(Color_Model(classDecision).ClassName), tok);
    tLine = fgetl(labelFile);
end

total  = countCor + countWrong
corPct = countCor / total
wngPct = countWrong / total