fileNames = dir('tryout_bw/');

distRatio = 0.6; 

for i = 3:size(fileNames,1)
    fileNames(i).name
    [im,desc,locs] = sift(strcat('tryout_bw/',fileNames(i).name));
    desct = desc';
    for j = 1:size(AppleModel,1)
        dotprods = AppleModel(j,:) * desct;
        d = min(acos(dotprods));
        
        %[vals,indx] = sort(acos(dotprods));
        
        %if(vals(1) < distRatio * vals(2))
        %    m(j) = 1;
        %else
        %    m(j) = 0;
        %end
    end
    matchscore = sum(m)
end