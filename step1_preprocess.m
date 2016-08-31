function[success] = step1_preprocess(s_path,d_path_gray)

fileNames = dir(s_path); %dir(strcat(s_path,className));

for i = 3:size(fileNames,1)
    fileNames(i).name
    [hsv_im,gray_im] = preprocess(strcat(s_path,fileNames(i).name));
   % imwrite(hsv_im,strcat(d_path_hsv,className,fileNames(i).name));
    imwrite(gray_im,strcat(d_path_gray,fileNames(i).name));
end

    success=1;