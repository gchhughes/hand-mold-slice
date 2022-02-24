%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ImportROIs                                                           %
%   CASIT                                                                %
%   Author: Griffith Hughes                                              %
%   Date:   01/12/2022                                                   %
%   Imports ROI information in a structure                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [s] = ImportROIs(filename,path)
[~,~,c] = xlsread(filename,'InProgress');    % Switched to xlsread because it NaN cells w/out data; edit to select sheet
sz = size(c);
s = struct([]); % Create an empty structure

%% Sort Spreadsheet (Section may require changes depending on spreadsheet format)
for ii = 1:sz(1)
    wm = cell(1,((sz(2)/2)-1));
    mr = cell(1,((sz(2)/2)-1));
    k = 1;
    l = 1;
    for j = 5:sz(2)
        if mod(j,2) == 1
            wm(k) = c(ii,j);
            k = k+1;
        elseif mod(j,2) ~= 1
            mr(l) = c(ii,j);
            l = l+1;
        end
    end
    maskNaN = cell2mat(cellfun(@(x)any(isnan(x)),mr,'UniformOutput',false)); % Identify NaN cells
    maskEmpty = cell2mat(cellfun(@(x)any(isempty(x)),mr,'UniformOutput',false)); % Identify [] cells
    mask = logical(maskNaN+maskEmpty); % Remove NaN and [] cells
    wm(mask) = [];
    mr(mask) = [];
    s(ii).id = c(ii,1);
    s(ii).wm = wm;
    s(ii).mr = mr;
end

%% Create Slice Structures
for i = 1:sz(1)
    [~,m] = size(s(i).wm);
    folder = strcat(path,s(i).id{:});
    for j = 1:m
        % ROI data for MR
        s(i).slice(j).mrNum = cell2mat(s(i).mr(j));
        roiLocation = strcat(folder,'\MR',mat2str(s(i).slice(j).mrNum),'.roi');
        [s(i).slice(j).mrMask,s(i).slice(j).mrData,s(i).slice(j).mrKey] = mrROIs(roiLocation);
        [s(i).slice(j).mrProstate,s(i).slice(j).mrPz,s(i).slice(j).mrTz,s(i).slice(j).mrTumor1,s(i).slice(j).mrTumor2,s(i).slice(j).mrTumor3] = SortROIs(s(i).slice(j).mrData);
        mrFile = strcat('MR',mat2str(s(i).slice(j).mrNum),'\n');
        fprintf(mrFile);
        
        % ROI data for WM
        s(i).slice(j).wmNum = regexprep(s(i).wm(j),'[^0-9-]','');
        % s(i).slice(j).wmNum = cell2mat(s(i).slice(j).wmNum);
        roiLocation = strcat(folder,'\WM',s(i).slice(j).wmNum,'.roi');
        [s(i).slice(j).wmMask,s(i).slice(j).wmData,s(i).slice(j).wmKey] = wmROIs(roiLocation{:});
        [s(i).slice(j).wmProstate,s(i).slice(j).wmPz,s(i).slice(j).wmTz,s(i).slice(j).wmTumor1,s(i).slice(j).wmTumor2,s(i).slice(j).wmTumor3] = SortROIs(s(i).slice(j).wmData);
        wmFile = strcat('WM',s(i).slice(j).wmNum{:},'\n');
        fprintf(wmFile);
    end
end
