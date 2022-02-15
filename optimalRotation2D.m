function [ rotatedPoints, rotationAngle ] = optimalRotation2D( rotPoint, refPoint, rotStep, rotLimit, cpNum, coCentroid )
%given ordered lists of points representing a surface to rotate and a
%reference surface, rotates first surface to be optimally aligned with the
%second surface, then outputs the rotated points and the optimum rotation
%angle. Warning: ONLY WORKS FOR DENSELY SAMPLED SURFACES THAT ALREADY SHARE
%A CENTROID

%i = 14; rotPoint = coreg(s).slide(i).ppList; refPoint = slice(i).pContour;
%rotStep = 0.1; rotLimit = 7; cpNum = 48;coCentroid = slice(i).pCentroid;

%Reset Test Variables
%{
i = 5;
rotPoint = coreg(s).slide(i).ppListBR;
refPoint = slice(s+sliceOffset(i)).pContour;
rotStep = 1;
rotLimit = 7;
cpNum = 48;
coCentroid = slice(s+sliceOffset(i)).pCentroid;

rotPoint = coreg(s).slide(i).ppListBR;
refPoint = slice(s+sliceOffset(i)).pContour;
rotStep = 0.5;
rotLimit = 10;
cpNum = 48;
coCentroid = slice(s+sliceOffset(i)).pCentroid;
coreg(s).slide(i).ppListBR

figure; hold on; plot(circleCP(1:end,1),circleCP(1:end,2),'Marker','x');
plot(refInt(1:end,1),refInt(1:end,2),'r','Marker','o');
%}

%% Step 0: use default values if inputs were unspecified
if nargin < 3
    rotStep = 0.1;
end

if nargin < 4
    rotLimit = 180-rotStep;
end

if nargin < 5
    cpNum = 48;
end

%% Step 2: Determine Centroids, translate both surfaces to zero
if nargin < 6
    
    maxX = max(max(rotPoint(1:end,1)),max(refPoint(1:end,1)));
    maxY = max(max(rotPoint(1:end,2)),max(refPoint(1:end,2)));
    maxXY = max(maxX, maxY);
    rotMask = roipoly(round(maxXY),round(maxXY),round(rotPoint(1:end,1)),round(rotPoint(1:end,2)));
    refMask = roipoly(round(maxXY),round(maxXY),round(refPoint(1:end,1)),round(refPoint(1:end,2)));
    rotProps = regionprops(rotMask,'Centroid');
    refProps = regionprops(refMask,'Centroid');
    rotCentroid = rotProps.Centroid;
    refCentroid = refProps.Centroid;
    
    rotPoint = rotPoint(1:end,1:2) - repmat(rotCentroid,length(rotPoint),1);
    refPoint = refPoint(1:end,1:2) - repmat(refCentroid,length(refPoint),1);
    
else
    
    rotPoint = rotPoint(1:end,1:2) - repmat(coCentroid,length(rotPoint),1);
    refPoint = refPoint(1:end,1:2) - repmat(coCentroid,length(refPoint),1);
    
end

maxX = max(max(rotPoint(1:end,1)),max(refPoint(1:end,1)));
maxY = max(max(rotPoint(1:end,2)),max(refPoint(1:end,2)));
maxXY = sqrt(max(maxX, maxY)^2+max(maxX, maxY)^2);

%% Step 2.5: subsample rotPoint so it has a number of points roughly equal to refPoint
rotOverRef = round(size(rotPoint,1)/size(refPoint,1));
rotPointSave = rotPoint;
rotPoint = rotPoint(1:7:end,1:end);

%% Step 3: Define the vector circle, and loop the pointsets
circleCP = vectorCircle(48)*(maxXY+1);
circleCPunitVec = vectorCircle(48);
rotPoint = vertcat(rotPoint,rotPoint(1,1:2));
refPoint = vertcat(refPoint,refPoint(1,1:2));
%prostateDistList = listDist([0,0,0],[refPoint,zeros(length(refPoint),1)]);
for k = 1:size(refPoint,1)
    refPointNorm(k,1:2) = refPoint(k,1:2)/norm(refPoint(k,1:2));
end

%% Step 4: Pre-Calculate the intersection points of circleCp with refPoint
for k = 1:cpNum
    
    %unitVecScaled = repmat(circleCP(k,1),size(),1)
    dotProductAll = dot(repmat(circleCPunitVec(k,:),size(refPointNorm,1),1),refPointNorm,2);
    [~,indexClosestTo1] = max(dotProductAll);
    refInt(k,1:2) = refPoint(indexClosestTo1,:);
    
    %Old slow method, commented out
    %{
    for j = 1:(size(refPoint,1)-1)
        [temp1, temp2] = polyxpoly([refPoint(j,1),refPoint(j+1,1)],[refPoint(j,2),refPoint(j+1,2)],[0,circleCP(k,1)],[0,circleCP(k,2)]);
        if isempty(temp1) == 0
            refInt(k,1:2) = [temp1,temp2];
        end
    end
    %}
end 

%For visualization
%{
figure; plot(refPoint(:,1),refPoint(:,2));
hold on;
for j = 1:size(circleCP,1)
plot([circleCP(j,1),0],[circleCP(j,2),0]);
end
plot(refInt(:,1),refInt(:,2),'Marker','o','Color','k')
plot(refInt2(:,1),refInt2(:,2),'Marker','x','Color','r')
%}

%% Step 4.5: Pre-Allocate which set of points in rotPoint will be tested for each circle CP
rotTrial((rotLimit/rotStep*2+1)).angle = 1;

for i = [-rotLimit,rotLimit];
    
    if i == -rotLimit
        trialNum = 1;
    else
        trialNum = rotLimit/rotStep*2+1;
    end
    
    rotTrial(trialNum).angle = i; %record angle of the trial
    rotTrial(trialNum).matrix = [cos(rotTrial(trialNum).angle*pi/180),-sin(rotTrial(trialNum).angle*pi/180);
        sin(rotTrial(trialNum).angle*pi/180),cos(rotTrial(trialNum).angle*pi/180)];
    
    for j = 1:size(rotPoint,1)
        rotTemp(j,1:2) = (rotTrial(trialNum).matrix*rotPoint(j,1:2)')';
        rotTempNorm(j,1:2) = rotTemp(j,1:2)/norm(rotTemp(j,1:2));
    end
    
    for k = 1:cpNum
        
        %unitVecScaled = repmat(circleCP(k,1),size(),1)
        dotProductAll = dot(repmat(circleCPunitVec(k,:),size(rotTempNorm,1),1),rotTempNorm,2);
        [~,indexClosestTo1] = max(dotProductAll);
        temp1 = rotTemp(indexClosestTo1,1);
        temp2 = rotTemp(indexClosestTo1,2);
        j = indexClosestTo1;
        
        %for j = 1:(size(rotPoint,1)-1)
            
            %[temp1,temp2] = polyxpoly([rotTemp(j,1),rotTemp(j+1,1)],[rotTemp(j,2),rotTemp(j+1,2)],[0,circleCP(k,1)],[0,circleCP(k,2)]);
            
            if isempty(temp1) == 0
                rotInt(k,1:2) = [temp1,temp2];
                rotTrial(trialNum).rotError(k) = (rotInt(k,1) - refInt(k,1))^2 + (rotInt(k,2) - refInt(k,2))^2;
                
                if i == -rotLimit
                    rotLowerIndex(k) = j;
                else
                    rotUpperIndex(k) = j;
                    
                    if rotUpperIndex(k) > rotLowerIndex(k)
                        cp(k).indexRange = [1:rotLowerIndex(k),rotUpperIndex(k):size(rotPoint,1)-1];
                    elseif rotLowerIndex == 1
                        
                        
                    else
                        cp(k).indexRange = rotUpperIndex(k):rotLowerIndex(k);
                    end
                end
            end
             
        %end
    end
    
    rotTrial(trialNum).totalError = sum(rotTrial(trialNum).rotError);
    
end

%% Step 5: rotate rotPoints in rotStep increments, and measure the circleCP intersects for all rotations

trialNum = 1;
for i= (-rotLimit+rotStep):rotStep:(rotLimit-rotStep)
    
    trialNum = trialNum + 1;
    rotTrial(trialNum).angle = i; %record angle of the trial
    
    rotTrial(trialNum).matrix = [cos(rotTrial(trialNum).angle*pi/180),-sin(rotTrial(trialNum).angle*pi/180);
        sin(rotTrial(trialNum).angle*pi/180),cos(rotTrial(trialNum).angle*pi/180)];
    
    for j = 1:size(rotPoint,1)
        rotTemp(j,1:2) = (rotTrial(trialNum).matrix*rotPoint(j,1:2)')';
        rotTempNorm(j,1:2) = rotTemp(j,1:2)/norm(rotTemp(j,1:2));
    end
    
    for k = 1:cpNum
        
        %unitVecScaled = repmat(circleCP(k,1),size(),1)
        dotProductAll = dot(repmat(circleCPunitVec(k,:),size(rotTempNorm,1),1),rotTempNorm,2);
        [~,indexClosestTo1] = max(dotProductAll);
        temp1 = rotTemp(indexClosestTo1,1);
        temp2 = rotTemp(indexClosestTo1,2);
        j = indexClosestTo1;
        
        %for j = cp(k).indexRange
            
            %[temp1,temp2] = polyxpoly([rotTemp(j,1),rotTemp(j+1,1)],[rotTemp(j,2),rotTemp(j+1,2)],[0,circleCP(k,1)],[0,circleCP(k,2)]);
            
            if isempty(temp1) == 0
                rotInt(k,1:2) = [temp1,temp2];
                rotTrial(trialNum).rotError(k) = (rotInt(k,1) - refInt(k,1))^2 + (rotInt(k,2) - refInt(k,2))^2;
            end
        %end
    end
    
        
    %Debugging code
    %{
    figure; hold on; plot(circleCP(1:end,1),circleCP(1:end,2),'Marker','x');
    plot(refInt(1:end,1),refInt(1:end,2),'r','Marker','o');
    plot(rotInt(1:end,1),rotInt(1:end,2),'g','Marker','o');
    hold off
    %}
    
    rotTrial(trialNum).totalError = sum(rotTrial(trialNum).rotError);
end

%% Step 6: Determine minimum, finalize output

[minError, minIndex] = min([rotTrial.totalError]);

for j = 1:size(rotPointSave,1)
    rotatedPoints(j,1:2) = (rotTrial(minIndex).matrix*rotPointSave(j,1:2)')';
end

rotationAngle = rotTrial(minIndex).angle;

%% Step 7 (Optional): Visualise optimized rotation, and plot of error vs. rotation angle
%
% figure; hold on;
% plot(refPoint(1:end,1),refPoint(1:end,2),'Color','k');
% plot(rotPoint(1:end,1),rotPoint(1:end,2),'Color','r');
% plot(rotatedPoints(1:end,1),rotatedPoints(1:end,2),'Color','g')
% figure;
% plot(1:length(rotTrial),[rotTrial.totalError]);
%

%% Shift output back to previous position

if nargin < 6
    rotatedPoints = rotatedPoints(1:end,1:2) + repmat(rotCentroid,length(rotatedPoints),1);  
else
    rotatedPoints = rotatedPoints(1:end,1:end) + repmat(coCentroid,length(rotatedPoints),1);
end

end

