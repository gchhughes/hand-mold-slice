%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   SortROIs                                                             %
%   CASIT                                                                %
%   Author: Jake Pensa                                                   %
%   Date:   01/18/2022                                                   %
%   Adds trace name to mask data points                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ProstateData,PzData,TzData,TumorData1,TumorData2,TumorData3] = SortROIs(data)
ProstateData = {};
PzData = {};
TzData = {};
TumorData1 = {};
TumorData2 = {};
TumorData3 = {};
[n,m] = size(data);
if m~=4
    fprintf('No Label on...')
    return
end

%% Sort Traces
for i = 1:n
    if strcmp(char(data{i,4}),'prostate')
        ProstateData(i,:) = data(i,:);
    end
    if strcmp(char(data{i,4}),'PZ')
        PzData(i,:) = data(i,:);
    end
    if strcmp(char(data{i,4}),'TZ')
        TzData(i,:) = data(i,:);
    end
    if strcmp(char(data{i,4}),'1')
        TumorData1(i,:) = data(i,:);
    end
    if strcmp(char(data{i,4}),'2')
        TumorData2(i,:) = data(i,:);
    end
    if strcmp(char(data{i,4}),'3')
        TumorData3(i,:) = data(i,:);
    end
end
emptyCells = cellfun('isempty', ProstateData);
ProstateData(all(emptyCells,2),:) = [];
emptyCells = cellfun('isempty', PzData);
PzData(all(emptyCells,2),:) = [];
emptyCells = cellfun('isempty', TzData);
TzData(all(emptyCells,2),:) = [];
emptyCells = cellfun('isempty', TumorData1);
TumorData1(all(emptyCells,2),:) = [];
emptyCells = cellfun('isempty', TumorData2);
TumorData2(all(emptyCells,2),:) = [];
emptyCells = cellfun('isempty', TumorData3);
TumorData3(all(emptyCells,2),:) = [];

%% Jake's Code
% for i = 1:n
%     if strcmp(char(data{i,4}),'PZ')
%         PzData(i,:) = data(i,:);
%     end
% end
% emptyCells = cellfun('isempty', PzData);
% PzData(all(emptyCells,2),:) = [];
% 
% for i = 1:n
%     if strcmp(char(data{i,4}),'TZ')
%         TzData(i,:) = data(i,:);
%     end
% end
% emptyCells = cellfun('isempty', TzData);
% TzData(all(emptyCells,2),:) = [];
% 
% for i = 1:n
%     if strcmp(char(data{i,4}),'1')
%         TumorData1(i,:) = data(i,:);
%     end
% end
% emptyCells = cellfun('isempty', TumorData1);
% TumorData1(all(emptyCells,2),:) = [];
% 
% for i = 1:n
%     if strcmp(char(data{i,4}),'2')
%         TumorData2(i,:) = data(i,:);
%     end
% end
% emptyCells = cellfun('isempty', TumorData2);
% TumorData2(all(emptyCells,2),:) = [];
% 
% for i = 1:n
%     if strcmp(char(data{i,4}),'3')
%         TumorData3(i,:) = data(i,:);
%     end
% end
% emptyCells = cellfun('isempty', TumorData3);
% TumorData3(all(emptyCells,2),:) = [];