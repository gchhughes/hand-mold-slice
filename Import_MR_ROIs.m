%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Import_MR_ROIs                                                       %
%   CASIT                                                                %
%   Author: Griffith Hughes                                              %
%   Date:   01/12/2022                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [mask,data,key] = Import_MR_ROIs(filename)
filename = 'C:\Users\griff\Downloads\segmentation\10042_1_03OZYDY8\MR10.roi';
d = importdata(filename);
sz = size(d);
count = 1;  % Count number of datapoints per trace to create matrix
old = 1;
trace = 1;  % Count the number of traces
key = [];
form = '{\d*.\d*,\s\d*.\d*}††'; % Look for data that has the form: {'{180.55561828613281, 176.70474243164062}††'}
xPoint = '\d*.\d*,';
yPoint = '\d*.\d*}';
point = '[^0-9.]';

%% Parse the .ROI data
for i = 1:sz(1)
    x = char(d(i,1));
    match = regexp(x,form,'match');
    [~,m] = size(match);
    y = cell(3,m);
    for j = 1:m % Clean up the data points
        y(1,j) = match(1,j);
        z = regexp(match(1,j),xPoint,'match');
        y(2,j) = regexprep(z{:},point,'');
        z = regexp(match(1,j),yPoint,'match');
        y(3,j) = regexprep(z{:},point,'');
        b(count,1) = str2double(y(2,j));
        b(count,2) = str2double(y(3,j));
        b(count,3) = trace;
        count = count+1;
    end
    if count > old
        trace = trace+1;
    end
    old = count;
end
