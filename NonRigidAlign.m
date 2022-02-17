%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   NonRigidAlign                                                        %
%   CASIT                                                                %
%   Author: Jake Pensa                                                   %
%   Date:   01/18/2022                                                   %
%   Non-rigid alignment of WM and MR traces                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = NonRigidAlign(data)
n = size(data);
res = 2048;

for i = 1:n(2)
    m = size(data(i).slice);
    for j = 1:m(2)
        
        check = checkMatchedROIs(data(i).slice(j));
        if check(1) == 0 || check(2) == 0 || check(3) == 0
            continue               %% only for lack of labels
        end
        label = strcat('Patient ',num2str(i),' ','Slice ',num2str(j),'\n');
        fprintf(label);
        
        parameters = regionprops(poly2mask(data(i).slice(j).wmProstate(:,1),data(i).slice(j).wmProstate(:,2),res,res));
        [data(i).slice(j).ControlPts,data(i).slice(j).AmmendedTargets] = linearSlopeControlPointGenV2(data(i).slice(j).mrProstate,data(i).slice(j).wmProstate,parameters.Centroid); %Need other version
        [data(i).slice(j).tParam,data(i).slice(j).NewWM_Prostate]=tpsWarp(data(i).slice(j).ControlPts,data(i).slice(j).AmmendedTargets,data(i).slice(j).wmProstate);
        
        [data(i).slice(j).tParam,data(i).slice(j).NewWM_Tz] = tpsWarp(data(i).slice(j).ControlPts,data(i).slice(j).AmmendedTargets,data(i).slice(j).wmTz);
        [data(i).slice(j).tParam,data(i).slice(j).NewWM_Pz] = tpsWarp(data(i).slice(j).ControlPts,data(i).slice(j).AmmendedTargets,data(i).slice(j).wmPz);
        
        if check(4) == 1
            [data(i).slice(j).tParam,data(i).slice(j).NewWM_Tumor1] = tpsWarp(data(i).slice(j).ControlPts,data(i).slice(j).AmmendedTargets,data(i).slice(j).wmTumor1);
        end
        
        if check(5) == 1
            [data(i).slice(j).tParam,data(i).slice(j).NewWM_Tumor2] = tpsWarp(data(i).slice(j).ControlPts,data(i).slice(j).AmmendedTargets,data(i).slice(j).wmTumor2);
        end
        
        if check(6) == 1
            [data(i).slice(j).tParam,data(i).slice(j).NewWM_Tumor3] = tpsWarp(data(i).slice(j).ControlPts,data(i).slice(j).AmmendedTargets,data(i).slice(j).wmTumor3);
        end
    end
end
