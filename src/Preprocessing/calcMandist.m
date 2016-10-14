function [classID, scores] = calcMandist( imgHist, Color_Model )

scores = zeros(size(Color_Model));

for class = 1:size(Color_Model,2)
    man_dist = zeros(size(Color_Model(class).Data,1),1);
    for idx = 1:size(Color_Model(class).Data,1)
        man_dist(idx) = sum(abs(imgHist-Color_Model(class).Data(idx, :)));
    end
    [A, B] = sort(man_dist);
    C = sum(A(1:10))/10;
    scores(class) = C;
end

[val, classID] = min(scores);

end