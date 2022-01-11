%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ImportROIs                                                           %
%   CASIT                                                                %
%   Author: Griffith Hughes                                              %
%   Date:   01/11/2022                                                   %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [patients] = Import-ROIs(folderLocation)
[filename,path] = uigetfile('*');
cd(path);
[~,~,c] = xlsread(filename);    % Switched to xlsread because it NaN cells w/out data
sz = size(c);
s = struct([]); % Create an empty structure

%% Sort Spreadsheet
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
        s(i).slices(j).mrNumb = s(i).mr(j);
        roiLocation = strcat(folder,'MR',s(i).mr(j),'.roi');
        
        % ROI data for WM
        s(i).slices(j).wmNumb = s(i).wm(j);
        roiLocation = strcat(folder,'WM',s(i).wm(j),'.roi');
    end
end
