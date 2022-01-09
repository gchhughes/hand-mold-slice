%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ImportROIs                                                          %
%   CASIT                                                                %
%   Author: Griffith Hughes                                              %
%   Date:   01/08/2022                                                   %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [patients] = Import-ROIs(folderLocation)
[filename,path] = uigetfile('*');
cd(path);

c = readcell(filename);
% t = cell2table(c);  % I was losing rows of data by going straight to table
sz = size(c);
s = struct([]); % Create an empty structure
% mask = cellfun(@isempty,c,'UniformOutput',false);
% mask = cell2mat(mask);

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
%         maskMR = cellfun(@ismissing,mr,'UniformOutput',false);
%         maskMR = cell2mat(maskMR);
%         wm(maskMR) = [];
%         mr(maskMR) = [];
    end
    %s(i).pt(i) = struct('id',a(i,1),'wm',wm,'mr',mr)
    s(i).id = c(i,1);
    s(i).wm = wm;
    s(i).mr = mr;
end