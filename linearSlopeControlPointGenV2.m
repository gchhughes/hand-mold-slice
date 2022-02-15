function [ cPoints, ammendedTargetList] = linearSlopeControlPointGenV2( targetList, pointList, theCentroid )
%Given a list of points (unordered is fine), a centroid, and a list of targets,
%generates a list of controlpoints that are intersections of the line
%perpendicular to each input target. Only works with targets that are spaced
%fairly close together.

%For testing: 
%{
i = 1;
pointList =  slice(s+sliceOffset(i)).pContour;
targetList = coreg(s).slide(i).ppList(1:10:end,:);
theCentroid = slice(s+sliceOffset(i)).pCentroid;
clear cPoints lineDist pointDist bHigh blow crossFlag crossFlag2 crossFlag3

%}

%%

targetListTemp = vertcat(targetList(end,1:2),targetList,targetList(1:2,1:2)); %Make the targetList circular

%%Generate the equations for all targets. Consider the target in question to
%be 'b', and its nearest neighbors 'a' before and 'c' afterwards.
for i = 2:length(targetList)+1
    acDiff = (targetListTemp(i+1,1:2)-targetListTemp(i-1,1:2));
    acOrth = [acDiff(2),-acDiff(1)];
    opSlopeUnitVec = acOrth/sqrt(acOrth(1)^2+acOrth(2)^2);
    bhigh(i-1,1:2) = targetListTemp(i,1:2) + opSlopeUnitVec*100;
    blow(i-1,1:2) = targetListTemp(i,1:2) - opSlopeUnitVec*100;
end

%%for each target line AND target point, compute and record the distance to
%all points in pointList. Then minimize that to find the matched point in
%pointList.
cInd = [];
for i = 1:length(targetList)
    for j = 1:length(pointList)
        lineDist(j) = point_to_line([pointList(j,1:2),0],[bhigh(i,1:2),0],[blow(i,1:2),0]);
        pointDist(j) = sqrt((pointList(j,1)-targetList(i,1))^2 + (pointList(j,2)-targetList(i,2))^2);
    end
    
    meanpointDist = mean(pointDist);
    minPointdist = min(pointDist);
    meanMinusMin = meanpointDist - minPointdist;
    %stdpointDist = std(pointDist); %max([minPointdist*3,meanpointDist/3,minPointdist+stdpointDist/2]);
    
    lineDist(pointDist(1:end)>(minPointdist+meanMinusMin/4)) = 10000;
    combDist = (lineDist .* pointDist);
    [minVal,minInd] = min(combDist);
    
    cInd = [cInd,minInd];
    cPoints(i,1:2) = pointList(minInd,1:2);
end

%%ADD A STEP TO CHECK FOR CROSSOVER; for all points with crossover, them and replace with a nearest-neighbor scheme or radial intersection scheme

crossFlag = zeros(size(targetList,1),1);
for i = 1:size(targetList,1)
    for j = 1:size(targetList,1)
        if i ~= j
            if isempty(polyxpoly([cPoints(i,1),targetList(i,1)],[cPoints(i,2),targetList(i,2)],[cPoints(j,1),targetList(j,1)],[cPoints(j,2),targetList(j,2)])) < 1
                crossFlag(i) = 1;
            end
        end
    end
end

%%Now Attempt a radial fix
crossFlag3 = zeros(size(targetList,1),1);
for i = 1:size(targetList,1)
    if crossFlag(i) > 0
       
        %Attempt to assign a match radially 
        tempVec = targetList(i,:)-theCentroid;
        [~,attemptedMatchInd] = minListDistanceToLine([theCentroid,0],[targetList(i,:),0]+[tempVec,0],[pointList,zeros(length(pointList),1)]);
        
        %tempDist = pdist2([pointList(attemptedMatchInd,1),targetList(i,1)],[pointList(attemptedMatchInd,2),targetList(i,2)]);
        %if tempDist > 30
            %floop
        %end
        
        %Check to see if that match intersects anything
        for j = 1:size(targetList,1)
            if i ~= j && crossFlag(j) < 1
                if isempty(polyxpoly([pointList(attemptedMatchInd,1),targetList(i,1)],[pointList(attemptedMatchInd,2),targetList(i,2)],[cPoints(j,1),targetList(j,1)],[cPoints(j,2),targetList(j,2)],'unique')) < 1
                    crossFlag3(i) = 1;
                end
            end
        end
        
        if crossFlag3(i) < 1
            cPoints(i,:) = pointList(attemptedMatchInd,:);
            crossFlag(i) = 0;
        end
    end
end

%%Attempt a nearest neighbor fix
crossFlag2 = zeros(size(targetList,1),1);
for i = 1:size(targetList,1)
    if crossFlag(i) > 0
        %Attempt to assign a nearest neighbor match
        [~,attemptedMatchInd] = minListDist([targetList(i,:),0],[pointList,zeros(length(pointList),1)]);
        
        %Check to see if that match intersects anything
        for j = 1:size(targetList,1)
            if i ~= j && crossFlag(j) < 1
                if isempty(polyxpoly([pointList(attemptedMatchInd,1),targetList(i,1)],[pointList(attemptedMatchInd,2),targetList(i,2)],[cPoints(j,1),targetList(j,1)],[cPoints(j,2),targetList(j,2)])) < 1
                    crossFlag2(i) = 1;
                end
            end
        end
        
        if crossFlag2(i) < 1
            cPoints(i,:) = pointList(attemptedMatchInd,:);
            crossFlag(i) = 0;
        end
    end
end

%%Now, KILL ALL CPOINTS THAT ARE GUILTY OF CROSSING
tempHold1 = cPoints;
tempHold2 = targetList;
cPoints = cPoints(crossFlag<1,:);
targetList = targetList(crossFlag<1,:);
ammendedTargetList = targetList;
 
%{
tempHold1 = cPoints;
tempHold2 = targetList;
tempHold3 = crossFlag;
cPoints = cPoints(crossFlag<1,:);
targetList = targetList(crossFlag<1,:);
cPoints = tempHold1;
targetList = tempHold2;
crossFlag = tempHold3;
%}

% Debugging Code
if 1 > 0
%     %%
%     %centroid = slice(s+sliceOffset(i)).pPointMean;targetList = slice(s+sliceOffset(i)).pContour;
%     %clear lineDist; clear pointDist;
%     %
%     %figure; hold on;
%     for i = 1:length(targetList)
%         %plot([blow(i,1),bhigh(i,1)],[blow(i,2),bhigh(i,2)],'Color','y');
%         %plot([cPoints(i,1),targetList(i,1)],[cPoints(i,2),targetList(i,2)],'Marker','x','Color','k');
%     end
%     
%     %%Now, KILL ALL CPOINTS THAT ARE GUILTY OF CROSSING
%     cPointsZ = tempHold1(crossFlag>0,:);
%     targetListZ = tempHold2(crossFlag>0,:);
%     for i = 1:size(cPointsZ,1)
%         %plot([blow(i,1),bhigh(i,1)],[blow(i,2),bhigh(i,2)],'Color','y');
%         %plot([cPointsZ(i,1),targetListZ(i,1)],[cPointsZ(i,2),targetListZ(i,2)],'Marker','x','Color','y');
%     end
%     
%     %plot(pointList(1:end,1),pointList(1:end,2));
%     %plot(targetList( 1:end,1),targetList(1:end,2),'Marker','o','Color','r');
%     %axis equal
%     %
end

end
