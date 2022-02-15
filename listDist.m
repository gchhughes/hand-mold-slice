function [ listOut ] = listDist(singlePoint,longList)
%Given a point and a List, computes the minimum distance between that list
%and that point in 3D space

tempDiff = longList-repmat(singlePoint,size(longList,1),1);
listOut = sqrt(tempDiff(1:end,1).^2 + tempDiff(1:end,2).^2 + tempDiff(1:end,3).^2);

end

