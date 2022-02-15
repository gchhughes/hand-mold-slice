function [ tParam, roiTran ] = tpsWarp(transPoint, refPoint, roiPoint)
%Given a set of matched reference and transformed control points, computes
%the parameters of a thin-plate spline based transformation between them.
%If a set of ROI points are supplied, automatically computes their
%transform and outputs it as well. Uses the technique described in Fei,
%Suri and Wilson, Handbook of Biomedical Image Analysis Vol III: Registration Models 

%i = 4; j = 1;
%refPoint = slice(s+sliceOffset(i)).pContour; transPoint = coreg(s).slide(i).pCp; roiPoint = coreg(s).slide(i).target(j).tpList;
% transPoint = WM.slice(i).ControlPts;
% refPoint = WM.slice(i).AmmendedTargets;
% roiPoint = WM.slice(i).trace(j).pts(:,1:2);
%If inputs are in 2D, make them 3D by adding zeros for z values
if size(transPoint,2) == 2
    transPoint(size(transPoint,1),3) = 0;
    refPoint(size(refPoint,1),3) = 0;
    roiPoint(size(roiPoint,1),3) = 0;
end

%First, define P, a matrix of control points in the reference volume
P = [ones(size(transPoint,1),1),transPoint];

K=pdist2(P,P);
% %Next, define K, a matrix of distances between 
% for i = 1:size(P,1)
%     for j = 1:size(P,1)
%         if i ~= j
%             K(i,j) = pdist2(P(i,1:end),P(j,1:end));
%         end
%     end
% end

%Next, define L, mystical matrix #1
L = vertcat([K,P],[transpose(P),zeros(4,4)]);

%Next, define V, which is just transPoint'
V = refPoint';

%transPoint plus some zeros
Y = transpose([V,zeros(3,4)]);

%Calculation of W and the alphas
Wtemp = pinv(L)*Y;
Wtemp2 = transpose(Wtemp);
W = Wtemp2(1:end,1:end-4);
alpha1 = Wtemp2(1:end,end-3);
alphaX = Wtemp2(1:end,end-2);
alphaY = Wtemp2(1:end,end-1);
alphaZ = Wtemp2(1:end,end);

%Record the transformation parameters for export
tParam.a1 = alpha1;
tParam.aX = alphaX;
tParam.aY = alphaY;
tParam.aZ = alphaZ;
tParam.W = W;
tParam.P = P;

for i = 1:size(roiPoint,1)
    
    %compute the sum term
    sumTerm = 0;
    for j = 1:size(tParam.P,1)
        %sumTerm = sumTerm + tParam.W(1:3,j)*pdist2(tParam.P(j,2:4),roiPoint(i,1:3));
        sumTerm = sumTerm + tParam.W(1:3,j)*sqrt((tParam.P(j,2)-roiPoint(i,1))^2+(tParam.P(j,3)-roiPoint(i,2))^2+(tParam.P(j,4)-roiPoint(i,3))^2);
    end
    
    roiTran(i,1:3) = tParam.a1 + tParam.aX*roiPoint(i,1) + tParam.aY*roiPoint(i,2) + tParam.aZ*roiPoint(i,3) + sumTerm;
    
end

%Graphing code for debugging. Enables visualization of original points
%relative to transformed ones.
%{
figure; hold on;
plot(refPoint(1:end,1),refPoint(1:end,2),'Color',[0 1 0]);
plot(transPoint(1:end,1),transPoint(1:end,2),'Color',[0 0 1]);
plot(roiPoint(1:end,1),roiPoint(1:end,2),'Color',[1 0 0]);
plot(roiTran(1:end,1),roiTran(1:end,2),'Color',[1 1 0]);
%}

%Now to implement the algorithm--DO LATER
%{
if exist(roiPoint)
    
    roiTran = applyTPStransform(tParam, roiPoint)
    
end
%}

end