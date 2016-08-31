function [classID, scores] = calcMandist( hHist, sHist, vHist, Color_Model )

scores = zeros(size(Color_Model));

for class = 1:size(Color_Model,2)
    
    if Color_Model(class).numModels ~= 0
        h_man_dist = zeros(size(Color_Model(class).hHist,1),1);
        for idx = 1:size(Color_Model(class).hHist,1)
            h_man_dist(idx) = sum(abs(hHist-Color_Model(class).hHist(idx, :)));
        end

        s_man_dist = zeros(size(Color_Model(class).sHist,1),1);
        for idx = 1:size(Color_Model(class).hHist,1)
            s_man_dist(idx) = sum(abs(sHist-Color_Model(class).sHist(idx, :)));
        end

        v_man_dist = zeros(size(Color_Model(class).vHist,1),1);
        for idx = 1:size(Color_Model(class).hHist,1)
            v_man_dist(idx) = sum(abs(vHist-Color_Model(class).vHist(idx, :)));
        end

        tempScores = 2*h_man_dist + s_man_dist + v_man_dist;

        wScores = tempScores / 3;

        scores(class) = min(wScores);
    else
        scores(class) = Inf;
    end
%     [A, B] = sort(man_dist);
%     C = sum(A(1:10))/10;
%     scores(class) = C;
end

[val, classID] = min(scores);

end