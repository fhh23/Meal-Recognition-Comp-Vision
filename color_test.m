path_to_images = 'Testing/TestingImages/';

%load('new_images/Z_hist_model/Color_Model.mat');
load('Seg_Images/Z_hist_model/Color_Model.mat');

load('SVMModels_rbf.mat');
SVMmodels = SVMModels_rbf;

numberOfLevelsForH = 36;
numberOfLevelsForS = 36;
numberOfLevelsForV = 36; 

fileID = fopen('colorResults.txt','w');
labelFile = fopen(strcat(path_to_images, 'label.txt'),'r');

fileNames = dir(strcat(path_to_images, '*.jpg'));
minval = zeros(length(fileNames), size(Color_Model, 2));
rankTests = zeros(length(fileNames), 1);

tLine = fgetl(labelFile);

countCor = 0;
countWrong = 0;
neighCount = 0;

count = 1;

corrDetects = zeros(size(Color_Model));
corrRejects = zeros(size(Color_Model));
totalImages = zeros(size(Color_Model));
totalNonImages = zeros(size(Color_Model));

timestamps = zeros(1, length(fileNames));

tic;
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
            [BB, labels] = seg_kmeans( rgbImage, nColors );
            break;
        catch ex
            nColors = nColors -1;
        end
    end
    %scores = zeros(nColors, length(Color_Model));
    scores = zeros(1, length(Color_Model));
    %testerscores = zeros(nColors, length(Color_Model));
    segImage = rgbImage;
    segRegion = rgbImage;
    imgRegion = rgbImage;
    for regionIdx = 1:nColors
        bbRegionArea = ((BB(regionIdx,2) - BB(regionIdx,1)+1) * (BB(regionIdx,4) - BB(regionIdx,3)+1));
        if bbRegionArea == size(rgbImage,1) * size(rgbImage,2)
            continue;
        else
            if nColors > 1
                segLabels = repmat(labels(regionIdx, :, :),[1 1 3]);
                segImage(segLabels == 0) = 0;
                segRegion = segImage(BB(regionIdx,1):BB(regionIdx,2), BB(regionIdx,3):BB(regionIdx,4), :);
                imgRegion = rgbImage(BB(regionIdx,1):BB(regionIdx,2), BB(regionIdx,3):BB(regionIdx,4), :);
            end
        end
    end
    
    [hHist, sHist, vHist] = hsvHistogram(segRegion, numberOfLevelsForH,numberOfLevelsForS, numberOfLevelsForV);

    [classId, scores] = calcMandist(hHist, sHist, vHist, Color_Model);
    
    mergedScores = scores;
%     for i=2:nColors
%         mergedScores = min(mergedScores, scores(i, :));
%     end
    %[dist, classDecision] = min(mergedScores);
    
    % FARHAN CODE
    [im,desc,locs] = test_sift(imgRegion);
    nclusters = 25;
%     while 1
%         try
%             [idx C] = kmeans(desc,nclusters); % learn 10 clusters from each image 
%             break;
%         catch ex
%             nclusters = nclusters -1;
%         end
%     end
    %[idx C] = kmeans(desc,nclusters); % learn 10 clusters from each image 
    testSiftModel = [desc];
    [B, I] = sort(mergedScores);
    I
    siftscores = [0];
    for i=1:3
        G = svmclassify(SVMmodels{I(i),1},testSiftModel);
        siftscores(i) = sum(G);
    end
    [dist, classDec] = max(siftscores);
    siftscores
    classDecision = I(classDec);
    classDecision
%     %FARHAN CODE -- END
    
    %[val, classDecision] = min(mergedScores);

    timestamps(count) = toc;
    
    
    [tok, rem] = strtok(rem);
    output = [fileName ': actual:' tok '  guess:' lower(Color_Model(classDecision).ClassName)]
    
    correctClass = 0;
    for class = 1:length(Color_Model)
       if strcmpi(Color_Model(class).ClassName,tok)
           correctClass = class;
           totalImages(class) = totalImages(class) + 1;
       else
           totalNonImages(class) = totalNonImages(class) + 1;
       end      
    end
    
    if classDecision == correctClass
        countCor = countCor + 1;
        corrDetects(classDecision) = corrDetects(classDecision) + 1;
        for class = 1:size(Color_Model,2)
            if classDecision ~= class
               corrRejects(class) = corrRejects(class) + 1;
            end
        end
    else
        for class = 1:size(Color_Model,2)
            if classDecision ~= class && correctClass ~= class
               corrRejects(class) = corrRejects(class) + 1;
            end
        end     
    end    

    
    
    count = count + 1;
    fprintf(fileID, '%s %s\n', fileName, lower(Color_Model(classDecision).ClassName));
    tLine = fgetl(labelFile);
end

totalTime = sum(timestamps);
aveTime = mean(timestamps);

pct1 = corrDetects./totalImages;
pct2 = corrRejects./totalNonImages;
output = pct1 + pct2;
rankOutput = output/2;
