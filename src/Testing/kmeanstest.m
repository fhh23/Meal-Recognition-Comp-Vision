strcat('imaged_tryout/*.jpg');
fileNames = dir(strcat('imaged_tryout/*.jpg'));

numberOfLevelsForH = 12;
numberOfLevelsForS = 1;
numberOfLevelsForV = 1; 

minval = zeros(length(fileNames), 10);
for fileIdx = 1:length(fileNames)
    fileName = strcat('imaged_tryout/',fileNames(fileIdx).name)
    rgbImage = imread(fileName);
    %Resize the image if it's too large
    if max(size(rgbImage))>1000
        ratio = max(size(rgbImage))/1000;
        rgbImage = imresize(rgbImage,1/ratio); 
    end
    imgHist = hsvHistogram(rgbImage, numberOfLevelsForH,numberOfLevelsForS, numberOfLevelsForV);
    tempHist = zeros(1, numberOfLevelsForH/2);
    for i = 1:size(tempHist,2)-1
        tempHist(i+1) = imgHist(2*i) + imgHist((2*i)+1);
    end
    tempHist(1) = imgHist(1) + imgHist(numberOfLevelsForH);
    
    count = 0;
    for i = 1:size(tempHist,2)
        if tempHist(i) > 1.0/size(tempHist,2)
            count = count +1;
        end
    end
    count
end