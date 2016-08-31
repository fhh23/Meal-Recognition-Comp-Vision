s_path = 'imaged_tryout/';
classes={'Apple/','Banana/','Broccoli/','Cookie/','Egg/',...
    'FrenchFries/','HotDog/','Rice/','Strawberry/','Tomato/','Utensils/'};
%classes={'Utensils/'};

%d_path_hsv = 'PreProcess_Images_hsv/';
d_path_gray = 'PreProcess_Images_Gray/';

%step1_result = step1_preprocess(s_path,d_path_gray);
%[siftModels,step2_result] = step2_extract_sift(d_path_gray,classes);
[SVMmodels,step3_result] = training_svm(SiftModel2);
