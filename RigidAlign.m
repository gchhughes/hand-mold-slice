%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   RigidAlign                                                           %
%   CASIT                                                                %
%   Author: Jake Pensa                                                   %
%   Date:   01/18/2022                                                   %
%   Rigid alignment of WM and MR traces                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = RigidAlign(data)
%data = s;

Rigid_Prostate = [];
Rigid_PZ = [];
Rigid_TZ = [];
Rigid_Tumor = {};
res = 2048;
[n,m] = size(data);

%% Find Rotation Metrics based on MR prostate
for i = 1:m
    q = size(data(i).slice);
    for j = 1:q(2)
        check = checkMatchedROIs(data(i).slice(j));
        if check(1) == 0 || check(2) == 0 || check(3) == 0
            continue               %% only for lack of labels
        end
        MRProstate = [];
        WMProstate = [];
        MRProstate1 = [];
        WM = [];
        MRProstate_Mask = poly2mask(cell2mat(data(i).slice(j).mrProstate(:,1)),cell2mat(data(i).slice(j).mrProstate(:,2)),res,res);
        MR_Parameters = regionprops(MRProstate_Mask,'Centroid','Area');
        WMProstate_Mask = poly2mask(cell2mat(data(i).slice(j).wmProstate(:,1)),cell2mat(data(i).slice(j).wmProstate(:,2)),res,res);
        WM_Parameters = regionprops(WMProstate_Mask,'Centroid','Area');
        
        C_Diff = WM_Parameters.Centroid - MR_Parameters.Centroid;
        WMProstate = cell2mat(data(i).slice(j).wmProstate(:,1:2));
        MRProstate1 = cell2mat(data(i).slice(j).mrProstate(:,1:2));
        WMProstate(:,1) = WMProstate(:,1) - WM_Parameters.Centroid(1);
        WMProstate(:,2) = WMProstate(:,2) - WM_Parameters.Centroid(2);
        MRProstate(:,1) = MRProstate1(:,1) - MR_Parameters.Centroid(1);
        MRProstate(:,2) = MRProstate1(:,2) - MR_Parameters.Centroid(2);
        MR_Mask = poly2mask(MRProstate(:,1),MRProstate(:,2),res,res);
        WM_Mask = poly2mask(WMProstate(:,1),WMProstate(:,2),res,res);
        New_MRParam = regionprops(MR_Mask,'Centroid','Area');
        New_WMParam = regionprops(WM_Mask,'Centroid','Area');
        [WM,theta] = optimalRotation2D(WMProstate,MRProstate);
        shift = sqrt(MR_Parameters.Area)/sqrt(WM_Parameters.Area);
        WM = WM*shift;
        WM(:,1) = WM(:,1) + MR_Parameters.Centroid(1);
        WM(:,2) = WM(:,2) + MR_Parameters.Centroid(2);
        WM_Mask = poly2mask(WM(:,1),WM(:,2),res,res);
        New_WMParam = regionprops(WM_Mask,'Centroid','Area');
        
        WMTz = cell2mat(data(i).slice(j).wmTz(:,1:2));
        MRTz = cell2mat(data(i).slice(j).mrTz(:,1:2));
        WMPz = cell2mat(data(i).slice(j).wmPz(:,1:2));
        MRPz = cell2mat(data(i).slice(j).mrPz(:,1:2));
        TzParam = regionprops(poly2mask(WMTz(:,1),WMTz(:,2),res,res),'Centroid');
        PzParam = regionprops(poly2mask(WMPz(:,1),WMPz(:,2),res,res),'Centroid');
        WMTz(:,1) = WMTz(:,1) - WM_Parameters.Centroid(1);
        WMTz(:,2) = WMTz(:,2) - WM_Parameters.Centroid(2);
        WMPz(:,1) = WMPz(:,1) - WM_Parameters.Centroid(1);
        WMPz(:,2) = WMPz(:,2) - WM_Parameters.Centroid(2);
        
        rotationMatrix = [cos(theta*pi/180),-sin(theta*pi/180); sin(theta*pi/180),cos(theta*pi/180)];
        for r = 1:size(WMTz)
            WMTz(r,:) = transpose(rotationMatrix*transpose(WMTz(r,:)));
        end
        for r = 1:size(WMPz)
            WMPz(r,:) = transpose(rotationMatrix*transpose(WMPz(r,:)));
        end
        WMTz = WMTz*shift;
        WMPz = WMPz*shift;
        WMTz(:,1) = WMTz(:,1) + MR_Parameters.Centroid(1);
        WMTz(:,2) = WMTz(:,2) + MR_Parameters.Centroid(2);
        WMPz(:,1) = WMPz(:,1) + MR_Parameters.Centroid(1);
        WMPz(:,2) = WMPz(:,2) + MR_Parameters.Centroid(2);
        
        data(i).slice(j).wmProstate = WM;
        data(i).slice(j).wmTz = WMTz;
        data(i).slice(j).wmPz = WMPz;
        data(i).slice(j).mrProstate = MRProstate1;
        data(i).slice(j).mrTz = MRTz;
        data(i).slice(j).mrPz = MRPz;
        
        if check(4) == 1
            WMTumor1 = cell2mat(data(i).slice(j).wmTumor1(:,1:2));
            MRTumor1 = cell2mat(data(i).slice(j).mrTumor1(:,1:2));
            TumorParam = regionprops(poly2mask(WMTumor1(:,1),WMTumor1(:,2),res,res));
            WMTumor1(:,1) = WMTumor1(:,1) - WM_Parameters.Centroid(1);
            WMTumor1(:,2) = WMTumor1(:,2) - WM_Parameters.Centroid(2);
            for r = 1:size(WMTumor1)
                WMTumor1(r,:) = transpose(rotationMatrix*transpose(WMTumor1(r,:)));
            end
            WMTumor1 = WMTumor1*shift;
            WMTumor1(:,1) = WMTumor1(:,1) + MR_Parameters.Centroid(1);
            WMTumor1(:,2) = WMTumor1(:,2) + MR_Parameters.Centroid(2);
            data(i).slice(j).wmTumor1 = WMTumor1;
            data(i).slice(j).mrTumor1 = MRTumor1;
        end
        
        if check(5) == 1
            WMTumor2 = cell2mat(data(i).slice(j).wmTumor2(:,1:2));
            MRTumor2 = cell2mat(data(i).slice(j).mrTumor2(:,1:2));
            TumorParam = regionprops(poly2mask(WMTumor2(:,1),WMTumor2(:,2),res,res));
            WMTumor2(:,1) = WMTumor2(:,1) - WM_Parameters.Centroid(1);
            WMTumor2(:,2) = WMTumor2(:,2) - WM_Parameters.Centroid(2);
            for r = 1:size(WMTumor2)
                WMTumor2(r,:) = transpose(rotationMatrix*transpose(WMTumor2(r,:)));
            end
            WMTumor2 = WMTumor2*shift;
            WMTumor2(:,1) = WMTumor2(:,1) + MR_Parameters.Centroid(1);
            WMTumor2(:,2) = WMTumor2(:,2) + MR_Parameters.Centroid(2);
            data(i).slice(j).wmTumor2 = WMTumor2;
            data(i).slice(j).mrTumor2 = MRTumor2;
        end
        
        if check(6) == 1
            WMTumor3 = cell2mat(data(i).slice(j).wmTumor3(:,1:2));
            MRTumor3 = cell2mat(data(i).slice(j).mrTumor3(:,1:2));
            TumorParam = regionprops(poly2mask(WMTumor3(:,1),WMTumor3(:,2),res,res));
            WMTumor3(:,1) = WMTumor3(:,1) - WM_Parameters.Centroid(1);
            WMTumor3(:,2) = WMTumor3(:,2) - WM_Parameters.Centroid(2);
            for r = 1:size(WMTumor3)
                WMTumor3(r,:) = transpose(rotationMatrix*transpose(WMTumor3(r,:)));
            end
            WMTumor3 = WMTumor3*shift;
            WMTumor3(:,1) = WMTumor3(:,1) + MR_Parameters.Centroid(1);
            WMTumor3(:,2) = WMTumor3(:,2) + MR_Parameters.Centroid(2);
            data(i).slice(j).wmTumor3 = WMTumor3;
            data(i).slice(j).mrTumor3 = MRTumor3;
        end
    end
end