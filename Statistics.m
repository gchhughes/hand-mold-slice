function [data] = Statistics(data)
n = size(data);
res = 512;
for i = 1:n(2)
    m = size(data(i).slice);
    for j = 1:m(2)
        check = checkMatchedROIs(data(i).slice(j));
        if check(1) == 0 || check(2) == 0 || check(3) == 0
            continue               %% only for lack of labels
        end
        
        %Create Masks for Prostate,Pz,Tz
        WM_Prostate = poly2mask(data(i).slice(j).NewWM_Prostate(:,1),data(i).slice(j).NewWM_Prostate(:,2),res,res);
        WM_Tz = poly2mask(data(i).slice(j).NewWM_Tz(:,1),data(i).slice(j).NewWM_Tz(:,2),res,res);
        WM_Pz = poly2mask(data(i).slice(j).NewWM_Pz(:,1),data(i).slice(j).NewWM_Pz(:,2),res,res);
        
        mrProstate = poly2mask(data(i).slice(j).mrProstate(:,1),data(i).slice(j).mrProstate(:,2),res,res);
        mrTz = poly2mask(data(i).slice(j).mrTz(:,1),data(i).slice(j).mrTz(:,2),res,res);
        mrPz = poly2mask(data(i).slice(j).mrPz(:,1),data(i).slice(j).mrPz(:,2),res,res);
        
        %Find Areas
        
        WM_Prostate_Area = regionprops(WM_Prostate,'Area','MajorAxisLength');
        WM_Tz_Area = regionprops(WM_Tz,'Area','MajorAxisLength');
        WM_Pz_Area = regionprops(WM_Pz,'Area','MajorAxisLength');
        MR_Prostate_Area = regionprops(mrProstate,'Area','MajorAxisLength');
        MR_Tz_Area = regionprops(mrTz,'Area','MajorAxisLength');
        MR_Pz_Area = regionprops(mrPz,'Area','MajorAxisLength');
        
        %Compute Ovelap and Overlap Percentage
        
        Prostate_Overlap = WM_Prostate.*mrProstate;
        Prostate_OverlapPercent = (sum(Prostate_Overlap)/sum(mrProstate))*100;
        
        Tz_Overlap = WM_Tz.*mrTz;
        Tz_OverlapPercent = (sum(Tz_Overlap)/sum(mrTz))*100;
        
        Pz_Overlap = WM_Pz.*mrPz;
        Pz_OverlapPercent = (sum(Pz_Overlap)/sum(mrPz))*100;
        
        %Dice Similarity Coefficient
        
        Prostate_Dice = sum(Prostate_Overlap*2)/(sum(WM_Prostate)+sum(mrProstate));
        Pz_Dice = sum(Pz_Overlap*2)/(sum(WM_Pz)+sum(mrPz));
        Tz_Dice = sum(Tz_Overlap*2)/(sum(WM_Tz)+sum(mrTz));
        
        %Hausdorff Distance
        
        [Hausdorff_Prostate,Prostate_Location] = findHausdorff(data(i).slice(j).NewWM_Prostate,data(i).slice(j).mrProstate);
        [Hausdorff_Tz,Tz_Location] = findHausdorff(data(i).slice(j).NewWM_Tz,data(i).slice(j).mrTz);
        [Hausdorff_Pz,Pz_Location] = findHausdorff(data(i).slice(j).NewWM_Pz,data(i).slice(j).mrPz);
        
      
        %Add in Tumors
        
        if check(4) == 1
            WM_Tumor1 = poly2mask(data(i).slice(j).NewWM_Tumor1(:,1),data(i).slice(j).NewWM_Tumor1(:,2),res,res);
            mrTumor1 = poly2mask(data(i).slice(j).mrTumor1(:,1),data(i).slice(j).mrTumor1(:,2),res,res);
            
            MR_Tumor1_Area = regionprops(mrTumor1,'Area','MajorAxisLength');
            WM_Tumor1_Area = regionprops(WM_Tumor1,'Area','MajorAxisLength');
            
            Tumor1_Overlap = WM_Tumor1.*mrTumor1;
            Tumor1_OverlapPercent = (sum(Tumor1_Overlap)/sum(mrTumor1))*100;
            
            Tumor1_Dice = sum(Tumor1_Overlap*2)/(sum(WM_Tumor1)+sum(mrTumor1));
            
            [Hausdorff_Tumor1,Tumor1_Location] = findHausdorff(data(i).slice(j).NewWM_Tumor1,data(i).slice(j).mrTumor1);
            
            data(i).slice(j).stat.WM_Tumor1_Area = WM_Tumor1_Area.Area;
            data(i).slice(j).stat.WM_Tumor1_Diameter = WM_Tumor1_Area.MajorAxisLength;
            data(i).slice(j).stat.MR_Tumor1_Area = MR_Tumor1_Area.Area;
            data(i).slice(j).stat.MR_Tumor1_Diameter = MR_Tumor1_Area.MajorAxisLength;
            
            data(i).slice(j).stat.Tumor1_Overlap = Tumor1_Overlap;
            data(i).slice(j).stat.Tumor1_OverlapPercent = Tumor1_OverlapPercent;
            
            data(i).slice(j).stat.Tumor1_Dice = Tumor1_Dice;
            data(i).slice(j).stat.Hausdorff_Tumor1 = [Hausdorff_Tumor1/(.6641*5),Tumor1_Location];
        end
        
        if check(5) == 1
            WM_Tumor2 = poly2mask(data(i).slice(j).NewWM_Tumor2(:,1),data(i).slice(j).NewWM_Tumor2(:,2),res,res);
            mrTumor2 = poly2mask(data(i).slice(j).mrTumor2(:,1),data(i).slice(j).mrTumor2(:,2),res,res);
            
            MR_Tumor2_Area = regionprops(mrTumor2,'Area','MajorAxisLength');
            WM_Tumor2_Area = regionprops(WM_Tumor2,'Area','MajorAxisLength');
            
            Tumor2_Overlap = WM_Tumor2.*mrTumor2;
            Tumor2_OverlapPercent = (sum(Tumor2_Overlap)/sum(mrTumor2))*100;
            
            Tumor2_Dice = sum(Tumor2_Overlap*2)/(sum(WM_Tumor2)+sum(mrTumor2));
            
            [Hausdorff_Tumor2,Tumor2_Location] = findHausdorff(data(i).slice(j).NewWM_Tumor2,data(i).slice(j).mrTumor2);
            
            data(i).slice(j).stat.WM_Tumor2_Area = WM_Tumor2_Area.Area;
            data(i).slice(j).stat.WM_Tumor2_Diameter = WM_Tumor2_Area.MajorAxisLength;
            data(i).slice(j).stat.MR_Tumor2_Area = MR_Tumor2_Area.Area;
            data(i).slice(j).stat.MR_Tumor2_Diameter = MR_Tumor2_Area.MajorAxisLength;
            data(i).slice(j).stat.Tumor2_Overlap = Tumor2_Overlap;
            data(i).slice(j).stat.Tumor2_OverlapPercent = Tumor2_OverlapPercent;
            data(i).slice(j).stat.Tumor2_Dice = Tumor2_Dice;
            data(i).slice(j).stat.Hausdorff_Tumor2 = [Hausdorff_Tumor2,Tumor2_Location];
        end
        
        if check(6) == 1
            WM_Tumor3 = poly2mask(data(i).slice(j).NewWM_Tumor3(:,1),data(i).slice(j).NewWM_Tumor3(:,2),res,res);
            mrTumor3 = poly2mask(data(i).slice(j).mrTumor3(:,1),data(i).slice(j).mrTumor3(:,2),res,res);
            
            MR_Tumor3_Area = regionprops(mrTumor3,'Area','MajorAxisLength');
            WM_Tumor3_Area = regionprops(WM_Tumor3,'Area','MajorAxisLength');
            
            Tumor3_Overlap = WM_Tumor3.*mrTumor3;
            Tumor3_OverlapPercent = (sum(Tumor3_Overlap)/sum(mrTumor3))*100;
            
            Tumor3_Dice = sum(Tumor3_Overlap*2)/(sum(WM_Tumor3)+sum(mrTumor3));
            
            [Hausdorff_Tumor3,Tumor3_Location] = findHausdorff(data(i).slice(j).NewWM_Tumor3,data(i).slice(j).mrTumor3);
            
            data(i).slice(j).stat.WM_Tumor3_Area = WM_Tumor3_Area.Area;
            data(i).slice(j).stat.WM_Tumor3_Diameter = WM_Tumor3_Area.MajorAxisLength;
            data(i).slice(j).stat.MR_Tumor3_Area = MR_Tumor3_Area.Area;
            data(i).slice(j).stat.MR_Tumor3_Diameter = MR_Tumor3_Area.MajorAxisLength;
            data(i).slice(j).stat.Tumor3_Overlap = Tumor3_Overlap;
            data(i).slice(j).stat.Tumor3_OverlapPercent = Tumor3_OverlapPercent;
            data(i).slice(j).stat.Tumor3_Dice = Tumor3_Dice;
            data(i).slice(j).stat.Hausdorff_Tumor3 = [Hausdorff_Tumor3,Tumor3_Location];
        end
        
        data(i).slice(j).stat.WM_Prostate_Area = WM_Prostate_Area.Area;
        data(i).slice(j).stat.WM_Prostate_Diameter = WM_Prostate_Area.MajorAxisLength;
        data(i).slice(j).stat.WM_Tz_Area = WM_Tz_Area.Area;
        data(i).slice(j).stat.WM_Tz_Diameter = WM_Tz_Area.MajorAxisLength;
        data(i).slice(j).stat.WM_Pz_Area = WM_Pz_Area.Area;
        data(i).slice(j).stat.WM_Pz_Diameter = WM_Pz_Area.MajorAxisLength;
        data(i).slice(j).stat.MR_Prostate_Area = MR_Prostate_Area.Area;
        data(i).slice(j).stat.MR_Prostate_Diameter = MR_Prostate_Area.MajorAxisLength;
        data(i).slice(j).stat.MR_Tz_Area = MR_Tz_Area.Area;
        data(i).slice(j).stat.MR_Tz_Diameter = MR_Tz_Area.MajorAxisLength;
        data(i).slice(j).stat.MR_Pz_Area = MR_Pz_Area.Area;
        data(i).slice(j).stat.MR_Pz_Diameter = MR_Pz_Area.MajorAxisLength;
        data(i).slice(j).stat.Prostate_Overlap = Prostate_Overlap;
        data(i).slice(j).stat.Prostate_OverlapPercent = Prostate_OverlapPercent;
        data(i).slice(j).stat.Tz_Overlap = Tz_Overlap;
        data(i).slice(j).stat.Tz_OverlapPercent = Tz_OverlapPercent;
        data(i).slice(j).stat.Pz_Overlap = Pz_Overlap;
        data(i).slice(j).stat.Pz_OverlapPercent = Pz_OverlapPercent;
        data(i).slice(j).stat.Prostate_Dice = Prostate_Dice;
        data(i).slice(j).stat.Tz_Dice = Tz_Dice;
        data(i).slice(j).stat.Pz_Dice = Pz_Dice;
        data(i).slice(j).stat.Hausdorff_Prostate = [Hausdorff_Prostate,Prostate_Location];
        data(i).slice(j).stat.Hausdorff_Tz = [Hausdorff_Tz,Tz_Location];
        data(i).slice(j).stat.Hausdorff_Pz = [Hausdorff_Pz,Pz_Location];
        
        f1 = figure('Position',[10,10,1000,1000]);
        
        subplot(2,2,1);
        hold on
        axis equal
        a = [data(i).slice(j).NewWM_Tz(Tz_Location(1),1:2);data(i).slice(j).mrTz(Tz_Location(2),1:2)];
        plot(data(i).slice(j).mrProstate(:,1),data(i).slice(j).mrProstate(:,2)*-1,'red');
        plot(data(i).slice(j).NewWM_Prostate(:,1),data(i).slice(j).NewWM_Prostate(:,2)*-1,'blue');
        plot(data(i).slice(j).mrTz(:,1),data(i).slice(j).mrTz(:,2)*-1,'green');
        plot(data(i).slice(j).NewWM_Tz(:,1),data(i).slice(j).NewWM_Tz(:,2)*-1,'black')
        %plot(a(:,1),a(:,2),'magenta')
        legend('MR Prostate','WM Prostate','MR Tz','WM Tz','Location','southoutside','Orientation','horizontal')
        hold off
        subplot(2,2,2);
        hold on
        axis equal
        a = [data(i).slice(j).NewWM_Pz(Pz_Location(1),1:2);data(i).slice(j).mrPz(Pz_Location(2),1:2)];
        plot(data(i).slice(j).mrProstate(:,1),data(i).slice(j).mrProstate(:,2)*-1,'red');
        plot(data(i).slice(j).NewWM_Prostate(:,1),data(i).slice(j).NewWM_Prostate(:,2)*-1,'blue');
        plot(data(i).slice(j).mrPz(:,1),data(i).slice(j).mrPz(:,2)*-1,'green')
        plot(data(i).slice(j).NewWM_Pz(:,1),data(i).slice(j).NewWM_Pz(:,2)*-1,'black')
        %plot(a(:,1),a(:,2),'magenta')
        legend('MR Prostate','WM Prostate','MR Pz','WM Pz','Location','southoutside','Orientation','horizontal')
        hold off
        if check(4) == 1
            subplot(2,2,3);
            hold on
            axis equal
            a = [data(i).slice(j).NewWM_Tumor1(Tumor1_Location(1),1:2);data(i).slice(j).mrTumor1(Tumor1_Location(2),1:2)];
            plot(data(i).slice(j).mrProstate(:,1),data(i).slice(j).mrProstate(:,2)*-1,'red');
            plot(data(i).slice(j).NewWM_Prostate(:,1),data(i).slice(j).NewWM_Prostate(:,2)*-1,'blue');
            plot(data(i).slice(j).mrTumor1(:,1),data(i).slice(j).mrTumor1(:,2)*-1,'green')
            plot(data(i).slice(j).NewWM_Tumor1(:,1),data(i).slice(j).NewWM_Tumor1(:,2)*-1,'black')
            %plot(a(:,1),a(:,2),'magenta')
            legend('MR Prostate','WM Prostate','MR Tumor','WM Tumor','Location','southoutside','Orientation','horizontal')
            hold off
        end
        if check(5) == 1
            subplot(2,2,4);
            hold on
            axis equal
            a = [data(i).slice(j).NewWM_Tumor2(Tumor2_Location(1),1:2);data(i).slice(j).mrTumor2(Tumor2_Location(2),1:2)];
            plot(data(i).slice(j).mrProstate(:,1),data(i).slice(j).mrProstate(:,2)*-1,'red');
            plot(data(i).slice(j).NewWM_Prostate(:,1),data(i).slice(j).NewWM_Prostate(:,2)*-1,'blue');
            plot(data(i).slice(j).mrTumor2(:,1),data(i).slice(j).mrTumor2(:,2)*-1,'green')
            plot(data(i).slice(j).NewWM_Tumor2(:,1),data(i).slice(j).NewWM_Tumor2(:,2)*-1,'black')
            %plot(a(:,1),a(:,2),'magenta')
            legend('MR Prostate','WM Prostate','MR Tumor','WM Tumor','Location','southoutside','Orientation','horizontal')
            hold off
        end
        if check(6) == 1
            hold on
            a = [data(i).slice(j).NewWM_Tumor3(Tumor3_Location(1),1:2);data(i).slice(j).mrTumor3(Tumor3_Location(2),1:2)];
            plot(data(i).slice(j).mrTumor3(:,1),data(i).slice(j).mrTumor3(:,2)*-1,'green')
            plot(data(i).slice(j).NewWM_Tumor3(:,1),data(i).slice(j).NewWM_Tumor3(:,2)*-1,'black')
            %plot(a(:,1),a(:,2),'magenta')
            legend('MR Prostate','WM Prostate','MR Tumor','WM Tumor','Location','southoutside','Orientation','horizontal')
            hold off
        end
       
        
    end
end
