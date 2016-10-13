function hsvColorHistogram = hsvHistogram(image,numberOfLevelsForH,numberOfLevelsForS,numberOfLevelsForV)
% input: image to be quantized in hsv color space into 8x2x2 equal bins
% output: 1x32 vector indicating the features extracted from hsv color
% space

[rows, cols, numOfBands] = size(image);
% totalPixelsOfImage = rows*cols*numOfBands;
image = rgb2hsv(image);

% split image into h, s & v planes
h = image(:, :, 1);
s = image(:, :, 2);
v = image(:, :, 3);
v = histeq(v);

% quantize each h,s,v equivalently to 8x2x2
% Specify the number of quantization levels.
% thresholdForH = multithresh(h, 7);  % 7 thresholds result in 8 image levels
% thresholdForS = multithresh(s, 1);  % Computing one threshold will quantize ...
%                                     % the image into three discrete levels
% thresholdForV = multithresh(v, 1);  % 7 thresholds result in 8 image levels
%
% seg_h = imquantize(h, thresholdForH); % apply the thresholds to obtain segmented image
% seg_s = imquantize(s, thresholdForS); % apply the thresholds to obtain segmented image
% seg_v = imquantize(v, thresholdForV); % apply the thresholds to obtain segmented image

numberOfLevelsForH = double(numberOfLevelsForH);
numberOfLevelsForS = double(numberOfLevelsForS);
numberOfLevelsForV = double(numberOfLevelsForV);

% create final histogram matrix of size 8x2x2
hsvColorHistogram = zeros(numberOfLevelsForH, numberOfLevelsForS, numberOfLevelsForV);
% create col vector of indexes for later reference
index = zeros(rows*cols, 3);

% Put all pixels into one of the "numberOfLevels" levels.
count = 1;
for row = 1:size(h, 1)
    quantizedValueForHTemp = zeros(1, cols);
    quantizedValueForSTemp = zeros(1, cols);
    quantizedValueForVTemp = zeros(1, cols);
    for col = 1 : size(h, 2)

        quantizedValueForHTemp(col) = ceil(numberOfLevelsForH * h(row, col));
        % Needed due to matlab rounding errors.
        if quantizedValueForHTemp(col) > numberOfLevelsForH
           quantizedValueForHTemp(col) = double(numberOfLevelsForH);
        elseif quantizedValueForHTemp(col) < 1
            quantizedValueForHTemp(col) = 1.0;
        end
        quantizedValueForSTemp(col) = ceil(numberOfLevelsForS * s(row, col));
        % Needed due to matlab rounding errors.
        if quantizedValueForSTemp(col) > numberOfLevelsForS
           quantizedValueForSTemp(col) = double(numberOfLevelsForS);
        elseif quantizedValueForSTemp(col) < 1
            quantizedValueForSTemp(col) = 1.0;
        end
        quantizedValueForVTemp(col) = ceil(numberOfLevelsForV * v(row, col));
        % Needed due to matlab rounding errors.
        if quantizedValueForVTemp(col) > numberOfLevelsForV
           quantizedValueForVTemp(col) = double(numberOfLevelsForV);
        elseif quantizedValueForVTemp(col) < 1
            quantizedValueForVTemp(col) = 1.0;
        end
        
        % keep indexes where 1 should be put in matrix hsvHist
        index(count, 1) = quantizedValueForHTemp(col);
        index(count, 2) = quantizedValueForSTemp(col);
        index(count, 3) = quantizedValueForVTemp(col);
        count = count+1;
    end
end

% put each value of h,s,v to matrix 8x2x2
% (e.g. if h=7,s=2,v=1 then put 1 to matrix 8x2x2 in position 7,2,1)
for row = 1:size(index, 1)
    hsvColorHistogram(index(row, 1), index(row, 2), index(row, 3)) = ... 
        hsvColorHistogram(index(row, 1), index(row, 2), index(row, 3)) + 1;
end

% normalize hsvHist to unit sum
hsvColorHistogram = hsvColorHistogram(:)';
hsvColorHistogram = hsvColorHistogram/sum(hsvColorHistogram);

% clear workspace
clear('row', 'col', 'count', 'numberOfLevelsForH', 'numberOfLevelsForS', ...
    'numberOfLevelsForV', 'maxValueForH', 'maxValueForS', 'maxValueForV', ...
    'index', 'rows', 'cols', 'h', 's', 'v', 'image', 'quantizedValueForH', ...
    'quantizedValueForS', 'quantizedValueForV');

% figure('Name', 'Quantized leves for H, S & V');
% subplot(2, 3, 1);
% imshow(seg_h, []);
% subplot(2, 3, 2);
% imshow(seg_s, []);
% title('Quatized H,S & V by matlab function imquantize');
% subplot(2, 3, 3);
% imshow(seg_v, []);
% subplot(2, 3, 4);
% imshow(quantizedValueForH, []);
% subplot(2, 3, 5);
% imshow(quantizedValueForS, []);
% title('Quatized H,S & V by my function');
% subplot(2, 3, 6);
% imshow(quantizedValueForV, []);

end