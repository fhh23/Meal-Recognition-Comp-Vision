function [SVMmodels,success] = training_svm(siftModels)
%number of clusters
num_c = 500;

%total number of images (finally will be 500 for 10 classes)
total = 1000;

%labels for svm

%keep genuine class at top
clear labels
labels(1:num_c) = 1;

%rest labels
labels(num_c:total) = 0;

labels = labels';

SVMmodels = {};
%Generate different data and use same order of labels
for i=1:(size(siftModels,1)-1)
    p=randperm(size(siftModels{i,1},1));
    Model = siftModels{i,1};
    data = Model(p(1),:);
    for i=2:500
        data = [data; Model(p(i),:)];
    end
    
    p=randperm(5000);
    comboModel = [];
    for j=1:10
        if j ~= i
            comboModel = [comboModel; siftModels{j,1}];
        end
    end
                
    for k=1:500
        data = [data; comboModel(p(k),:)];
    end
    options = statset('MaxIter', 1500000);
    svm_model = svmtrain(data,labels, 'Options', options);
    SVMmodels = [SVMmodels; svm_model];
end
success = 1;