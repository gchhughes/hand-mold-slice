function [Hausdorff_Dist,Location] = findHausdorff(set1,set2)
minDist = [];
for q = 1:length(set1)
    tempDist = [9999,0,0];
    for w = 1:length(set2)
        pts = [set1(q,1:2);set2(w,1:2)];
        dist = pdist(pts);
        if dist < tempDist(1)
            tempDist(1) = dist;
            tempDist(2) = q;
            tempDist(3) = w;
        end
    end
    minDist(q,:) = tempDist;
end
Hausdorff_WM = max(minDist(:,1));

[a,~] = find(minDist(:,1) == Hausdorff_WM);
LocationWM = [minDist(a,2),minDist(a,3)];

minDist = [];

for q = 1:length(set2)
    tempDist = [9999,0,0];
    for w = 1:length(set1)
        pts = [set1(w,1:2);set2(q,1:2)];
        dist = pdist(pts);
        if dist < tempDist(1)
            tempDist(1) = dist;
            tempDist(2) = w;
            tempDist(3) = q;
        end
    end
    minDist(q,:) = tempDist;
end
Hausdorff_MR = max(minDist(:,1));

[a,~] = find(minDist(:,1) == Hausdorff_MR);
LocationMR = [minDist(a,2),minDist(a,3)];

Hausdorff_Dist = max([Hausdorff_WM,Hausdorff_MR]);

if Hausdorff_WM > Hausdorff_MR
    Location = LocationWM;
else
    Location = LocationMR;
end
