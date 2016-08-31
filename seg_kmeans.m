function [boundingBoxes, labels] = seg_kmeans( img, nColors )
boundingBoxes = zeros(nColors, 4);



%% Read in Image
he = img;
%imshow(he), title('H&E image');

%% Convert Image from RGB Color Space to L*a*b* Color Space
cform = makecform('srgb2lab');
lab_he = applycform(he,cform);

%% Classify the Colors in 'a*b*' Space Using K-Means Clustering
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

labels = zeros(nColors, nrows, ncols);

% repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
                                  
%% Label Every Pixel in the Image Using the Results from KMEANS
pixel_labels = reshape(cluster_idx,nrows,ncols);

%% Create Images that Segment the H&E Image by Color.
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors
    color = he;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

%% Perform Opening and Closing

se = strel('disk', 10);
for k = 1:nColors
    I = rgb2gray(segmented_images{k});
    Io = imopen(I, se);

    Ie = imerode(I, se);
    Iobr = imreconstruct(Ie, I);

    Iobrd = imdilate(Iobr, se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
    Iobrcbr = imcomplement(Iobrcbr);
    %Can be used to display the cluster regions
	labels(k, :, :) = Iobrcbr;
%     new_labels = repmat(Iobrcbr,[1 1 3]);
%     cleanImg = he;
%     cleanImg(new_labels == 0) = 0;
%     figure
%     imshow(cleanImg), title('Image after open-closing(recronstruction)');
    for r=1:nrows
        for c = 1:ncols
            if Iobrcbr(r, c) ~= 0
                if boundingBoxes(k, 1) == 0 || r < boundingBoxes(k, 1)
                    boundingBoxes(k, 1) = r;
                end
                if boundingBoxes(k, 2) == 0 || r > boundingBoxes(k, 2)
                    boundingBoxes(k, 2) = r;
                end
                if boundingBoxes(k, 3) == 0 || c < boundingBoxes(k, 3)
                    boundingBoxes(k, 3) = c;
                end
                if boundingBoxes(k, 4) == 0 || c > boundingBoxes(k, 4)
                    boundingBoxes(k, 4) = c;
                end
            end
        end
    end
    if max(boundingBoxes(k,:)) == 0
       boundingBoxes(k, :) = [ 1, nrows, 1, ncols];
    end
end

I = rgb2gray(img);
%imshow(I)

%% Use the Gradient Magnitude as the Segmentation Function
%I = histeq(I);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
%figure
%imshow(gradmag,[]), title('Gradient magnitude (gradmag)')

