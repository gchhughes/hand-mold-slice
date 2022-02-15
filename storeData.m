function [] = storeData(data)
[~,n] = size(data);
filename = 'Test.xlsx';
a = {'Patient','Slice','Zone','Area WM','Area MR','Diameter WM','Diameter MR','Overlap Percent','Dice','Hausdorff'};
row = 2;
sc = 0.1328;
for i = 1:n
    [~,m] = size(data(i).slice);
    for j = 1:m
        check = checkMatchedROIs(data(i).slice(j));
        if check(1) == 0 || check(2) == 0 || check(3) == 0
            continue               %% only for lack of labels
        end
        a(row,:) = {i,j,'Prostate',data(i).slice(j).stat.WM_Prostate_Area*((sc)^2),data(i).slice(j).stat.MR_Prostate_Area*((sc)^2),data(i).slice(j).stat.WM_Prostate_Diameter*(sc),data(i).slice(j).stat.MR_Prostate_Diameter*(sc),data(i).slice(j).stat.Prostate_OverlapPercent,data(i).slice(j).stat.Prostate_Dice,data(i).slice(j).stat.Hausdorff_Prostate(1)*(sc)};
        row = row + 1;
        a(row,:) = {i,j,'Tz',data(i).slice(j).stat.WM_Tz_Area*((sc)^2),data(i).slice(j).stat.MR_Tz_Area*((sc)^2),data(i).slice(j).stat.WM_Tz_Diameter*(sc),data(i).slice(j).stat.MR_Tz_Diameter*(sc),data(i).slice(j).stat.Tz_OverlapPercent,data(i).slice(j).stat.Tz_Dice,data(i).slice(j).stat.Hausdorff_Tz(1)*(sc)};
        row = row + 1;
        a(row,:) = {i,j,'Pz',data(i).slice(j).stat.WM_Pz_Area*((sc)^2),data(i).slice(j).stat.MR_Pz_Area*((sc)^2),data(i).slice(j).stat.WM_Pz_Diameter*(sc),data(i).slice(j).stat.MR_Pz_Diameter*(sc),data(i).slice(j).stat.Pz_OverlapPercent,data(i).slice(j).stat.Pz_Dice,data(i).slice(j).stat.Hausdorff_Pz(1)*(sc)};
        row = row + 1;
        if check(4) == 1
            a(row,:) = {i,j,'Tumor 1',data(i).slice(j).stat.WM_Tumor1_Area*((sc)^2),data(i).slice(j).stat.MR_Tumor1_Area*((sc)^2),data(i).slice(j).stat.WM_Tumor1_Diameter*(sc),data(i).slice(j).stat.MR_Tumor1_Diameter*(sc),data(i).slice(j).stat.Tumor1_OverlapPercent,data(i).slice(j).stat.Tumor1_Dice,data(i).slice(j).stat.Hausdorff_Tumor1(1)*(sc)};
            row = row + 1;
        end
        if check(5) == 1
            a(row,:) = {i,j,'Tumor 2',data(i).slice(j).stat.WM_Tumor2_Area*((sc)^2),data(i).slice(j).stat.MR_Tumor2_Area*((sc)^2),data(i).slice(j).stat.WM_Tumor2_Diameter*(sc),data(i).slice(j).stat.MR_Tumor2_Diameter*(sc),data(i).slice(j).stat.Tumor2_OverlapPercent,data(i).slice(j).stat.Tumor2_Dice,data(i).slice(j).stat.Hausdorff_Tumor2(1)*(sc)};
            row = row + 1;
        end
        if check(6) == 1
            a(row,:) = {i,j,'Tumor 3',data(i).slice(j).stat.WM_Tumor3_Area*((sc)^2),data(i).slice(j).stat.MR_Tumor3_Area*((sc)^2),data(i).slice(j).stat.WM_Tumor3_Diameter*(sc),data(i).slice(j).stat.MR_Tumor3_Diameter*(sc),data(i).slice(j).stat.Tumor3_OverlapPercent,data(i).slice(j).stat.Tumor3_Dice,data(i).slice(j).stat.Hausdorff_Tumor3(1)*(sc)};
            row = row + 1;
        end
        row = row + 1;
            
    end
end

xlswrite(filename,a);
     