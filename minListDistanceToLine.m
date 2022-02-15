function [ minDist, minIndOut, listDistAll] = minListDistanceToLine(staticOne,staticTwo,longList)
%Given two points and a list, computes the minimum distance between the
%vector describing the two points and the points within the list

%Test code:
%{
staticOne = voxelCoord(i,1:3);
staticTwo = mrFV(mrMatchTemp).vertices(tempIndSurface,1:3);
longList = negativeNodeAll;

staticOne = [theCentroid,0];
staticTwo = [targetList(i,:),0]+[tempVec,0];
longList = [pointList,zeros(length(pointList),1)];

staticOne = [laserBase,0];
staticTwo = [laserTip,0];
longList = [tElementPos,[0;0;0;0]];

staticOne = [laserBase+tProbeTipToBaseUnitVec*100,0]
staticTwo = [laserTip-tProbeTipToBaseUnitVec*100,0]
longList = [tElementPos,[0;0;0;0]]
%}

%%
staticVector = staticOne-staticTwo;
staticVectorDist = sqrt(sum(staticVector.^2));
staticVectorNorm = staticVector/norm(staticVector);
tempDiff = longList-repmat(staticTwo,size(longList,1),1);
tempDist = (tempDiff(:,1).^2+tempDiff(:,2).^2+tempDiff(:,3).^2).^0.5;
tempRep = repmat(staticVectorNorm,size(longList,1),1);

bigDot = dot(tempRep',tempDiff')';
bigCross = cross(tempRep',tempDiff')';
bigNorm = sqrt(bigCross(1:end,1).^2 + bigCross(1:end,2).^2 + bigCross(1:end,3).^2);
bigAngle = atan2(bigNorm,bigDot);
distanceToLine1 = sin(bigAngle).*tempDist;

%Stratify using distance from midpoint
staticMidPoint = (staticOne+staticTwo)/2;
tempDiffMid = longList-repmat(staticMidPoint,size(longList,1),1);
tempDistMid = (tempDiffMid(:,1).^2+tempDiffMid(:,2).^2+tempDiffMid(:,3).^2).^0.5;

distanceToLine = distanceToLine1;
distanceToLine(tempDistMid>(staticVectorDist/2)) = inf;

%%Now repeat, but taking the difference between longList and point 1 to avoid collecting points 180 degrees away 
%{
staticVector = staticTwo - staticOne;
staticVectorNorm = staticVector/norm(staticVector);
tempDiff = longList - repmat(staticTwo,size(longList,1),1);
tempDist = (tempDiff(:,1).^2+tempDiff(:,2).^2+tempDiff(:,3).^2).^0.5;
tempRep = repmat(staticVectorNorm,size(longList,1),1);

bigDot = dot(tempRep',tempDiff')';
bigCross = cross(tempRep',tempDiff')';
bigNorm = sqrt(bigCross(1:end,1).^2 + bigCross(1:end,2).^2 + bigCross(1:end,3).^2);
bigAngle = atan2(bigNorm,bigDot);
distanceToLine2 = sin(bigAngle).*tempDist;

distanceToLine = max(vertcat(distanceToLine1',distanceToLine2'));

min(distanceToLine1)
min(distanceToLine2)
%}

%%

[minDistanceToLine, minInd0] = min(distanceToLine);
[minDistanceToStatic1, minInd1] = minListDist(staticOne,longList);
[minDistanceToStatic2, minInd2] = minListDist(staticTwo,longList);
distanceToStatic1 = listDist(staticOne,longList);
distanceToStatic2 = listDist(staticTwo,longList);
listDistAll = min([distanceToLine,distanceToStatic1,distanceToStatic2]');
listDistAll = listDistAll';

minIndTriumvirate = [minInd0, minInd1, minInd2];
minDistTriumvirate = [minDistanceToLine,minDistanceToStatic1,minDistanceToStatic2];
[minDist, minIndInd] = min(minDistTriumvirate);
minIndOut = minIndTriumvirate(minIndInd);

%angleFiltered = bigAngle;
%angleFiltered(bigAngle>(pi/2)) = inf;
%distanceFiltered = tempDist;
%distanceFiltered(bigAngle>(pi/2)) = inf;

%{
[~, minInd1] = min(distanceToLine);

%Repeated with opposite vector order to bandaid bug
staticVector = staticTwo-staticOne;
tempDiff = longList-repmat(staticTwo,size(longList,1),1);
tempDist = (tempDiff(:,1).^2+tempDiff(:,2).^2+tempDiff(:,3).^2).^0.5;
tempRep = repmat(staticVector,size(longList,1),1);

bigDot = dot(tempRep',tempDiff')';
bigCross = cross(tempRep',tempDiff')';
bigNorm = sqrt(bigCross(1:end,1).^2 + bigCross(1:end,2).^2 + bigCross(1:end,3).^2);
bigAngle = atan2(bigNorm,bigDot);

smallEnoughAngle = bigAngle(bigAngle<(pi/2));
smallEnoughDistance = tempDist(bigAngle<(pi/2));
distanceToLine = sin(smallEnoughAngle).*smallEnoughDistance;
distanceToLine = [distanceToLine;minListDist(staticOne,longList);minListDist(staticTwo,longList)];

[~, minInd2] = min(distanceToLine);

[trueDistOne] = minListDist(longList(minInd1,:),[staticOne;staticTwo; inf inf inf; inf inf inf]);
[trueDistTwo] = minListDist(longList(minInd2,:),[staticOne;staticTwo; inf inf inf; inf inf inf]);

if trueDistOne<trueDistTwo
    minDist = trueDistOne;
    minIndOut = minInd1;
else
    minDist = trueDistTwo;
    minIndOut = minInd2;
end
%}


%code for testing: 
%figure; staticOne = ginput; staticTwo = ginput; longList = ginput; staticOne(3) = 0; staticTwo(3) = 0; longList(1:end,3) = 0;
%{
for i = 1:10000
    testPoint(i,1:2) = staticOne(1:2) +(staticTwo(1:2)-staticOne(1:2))*i/10000;
end
figure; hold on;
plot(staticOne(:,1),staticOne(:,2),'Marker','x');
plot(staticTwo(:,1),staticTwo(:,2),'Marker','x');
plot(testPoint(:,1),testPoint(:,2));
plot(longList(:,1),longList(:,2),'Marker','o');
axis equal
%}



end