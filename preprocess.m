function [hsv_im,gray_im] = preprocess(imname)
    im = imread(imname);
    [r,c,d]=size(im);
    
    if(max(r,c)>1000)
         ratio = max(r,c)/1000;
         im = imresize(im,1/ratio);
    end
    
    hsv_im = rgb2hsv(im);
    hsv_im(:,3) = histeq(hsv_im(:,3));
    
    gray_im = histeq(rgb2gray(im));