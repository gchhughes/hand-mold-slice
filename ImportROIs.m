%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ImportROIs                                                           %
%   CASIT                                                                %
%   Author: Griffith Hughes                                              %
%   Date:   01/12/2022                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [s] = ImportROIs(folderLocation)
[filename,path] = uigetfile('*');
cd(path);
[~,~,c] = xlsread(filename,'Ready');    % Switched to xlsread because it NaN cells w/out data; edit to select sheet
sz = size(c);
s = struct([]); % Create an empty structure

%% Sort Spreadsheet (Section may require changes depending on spreadsheet format)
for i = 1:sz(1)
    wm = cell(1,((sz(2)/2)-1));
    mr = cell(1,((sz(2)/2)-1));
    k = 1;
    l = 1;
    for j = 3:sz(2)
        if mod(j,2) == 1
            wm(k) = c(i,j);
            k = k+1;
        elseif mod(j,2) ~= 1
            mr(l) = c(i,j);
            l = l+1;
        end
    end
    maskMR = cell2mat(cellfun(@(x)any(isnan(x)),mr,'UniformOutput',false)); % Identify NaN cells
    wm(maskMR) = [];
    mr(maskMR) = [];
    s(i).id = c(i,1);
    s(i).wm = wm;
    s(i).mr = mr;
end

%% Create Slice Structures
for i = 1:sz(1)
    [~,m] = size(s(i).wm);
    folder = strcat(path,s(i).id{:});
    for j = 1:m
        % ROI data for MR
        s(i).slice(j).mrNum = cell2mat(s(i).mr(j));
        roiLocation = strcat(folder,'\MR',mat2str(s(i).slice(j).mrNum),'.roi');
        [s(i).slice(j).MR_Mask,s(i).slice(j).MR_Data,s(i).slice(j).MR_Key] = Import_MR_ROIs(roiLocation);
        [s(i).slice(j).MR_Prostate,s(i).slice(j).MR_Pz,s(i).slice(j).MR_Tz,s(i).slice(j).MR_Tumor1,s(i).slice(j).MR_Tumor2,s(i).slice(j).MR_Tumor3] = SortROIs(s(i).slice(j).MR_Data);
        MRfile = strcat('MR',mat2str(s(i).slice(j).mrNum),'\n');
        fprintf(MRfile);
        
        % ROI data for WM
        s(i).slice(j).wmNum = regexprep(s(i).wm(j),'[^0-9]','');
        s(i).slice(j).wmNum = cell2mat(s(i).slice(j).wmNum);
        roiLocation = strcat(folder,'\WM',s(i).slice(j).wmNum,'.roi');
        [s(i).slice(j).WM_Mask,s(i).slice(j).WM_Data,s(i).slice(j).WM_Key] = Import_WM_ROIs(roiLocation);
        [s(i).slice(j).WM_Prostate,s(i).slice(j).WM_Pz,s(i).slice(j).WM_Tz,s(i).slice(j).WM_Tumor1,s(i).slice(j).WM_Tumor2,s(i).slice(j).WM_Tumor3] = SortROIs(s(i).slice(j).WM_Data);
        WMfile = strcat('WM',s(i).slice(j).wmNum,'\n');
        fprintf(WMfile);
    end
end
