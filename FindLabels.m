%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FindLabels                                                           %
% CASIT                                                                %
% Author: Griffith Hughes                                              %
% Date:   02/18/2022                                                   %
% Parses through modified ROI file for trace labels                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [id] = FindLabels(filename)
% Import Data and Create Char Variable y
data = importdata(filename);
id = [];
n = size(data);
y = '';
for i = 1:n(1)
    y = [y,char(data(i))];
end

% Identify Locations of Labels
traceEnd = regexpi(y,'†††');
tzLoc = regexpi(y,'Tz');
pzLoc = regexpi(y,'Pz');
prostateLoc = regexpi(y,'prostate');
lesionLoc = regexpi(y,'lesion');
areaLoc = regexpi(y,'Area');

%% Determine Order of Labels
if areaLoc(1) < traceEnd(1)
    areaLoc = areaLoc(2:end);
end
n = size(traceEnd);
for i = 1:n(2)
    x = traceEnd(i);
    while x ~= areaLoc(i)
        if strcmp(y(x),'j')
            x = x+2;
        end
        if x == prostateLoc
            id{i} = 'prostate';
            traceEnd(i) - x;
            break
        elseif x == pzLoc
            id{i} = 'PZ';
            traceEnd(i) - x;
            break
        elseif x == tzLoc
            id{i} = 'TZ';
            traceEnd(i) - x;
            break
        elseif x == lesionLoc
            switch y(x+6)
                case '1'
                    id{i} = '1';
                case '2'
                    id{i} = '2';
                case '3'
                    id{i} = '3';
                case '4'
                    id{i} = '4';
                case '5'
                    id{i} = '5';
                case '6'
                    id{i} = '6';
                case '7'
                    id{i} = '7';
                case '8'
                    id{i} = '8';
                case '9'
                    id{i} = '9';
                otherwise
                    id{i} = '1';
            end
            traceEnd(i) - x;
            break
        end
        x = x+1;
    end
end
%% Lesion Number
% for ii = 1:size(lesionLoc)
%     switch y(lesionLoc(ii)+6)
%         case '1'
%             id{i} = '1';
%         case '2'
%             id{i} = '2';
%         case '3'
%             id{i} = '3';
%         case '4'
%             id{i} = '4';
%         case '5'
%             id{i} = '5';
%         case '6'
%             id{i} = '6';
%         case '7'
%             id{i} = '7';
%         case '8'
%             id{i} = '8';
%         case '9'
%             id{i} = '9';
%         otherwise
%             id{i} = '1';
%     end
% end