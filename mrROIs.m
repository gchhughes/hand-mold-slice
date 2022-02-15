%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   mrROIs                                                               %
%   CASIT                                                                %
%   Author: Griffith Hughes                                              %
%   Date:   01/12/2022                                                   %
%   Parse through MR.ROI file to create trace masks                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mask,d,key] = mrROIs(filename)
% filename = 'C:\Users\griff\Downloads\segmentation\10042_1_244PS323\MR11.roi';
data = importdata(filename);
sz = size(data);
count = 1;  % Count number of datapoints per trace to create matrix
old = count;
trace = 1;  % Count the number of traces
key = [];
form = '{\d*.\d*,\s\d*.\d*}††'; % Look for data that has the form: {'{180.55561828613281, 176.70474243164062}††'}
xPoint = '\d*.\d*,';
yPoint = '\d*.\d*}';
point = '[^0-9.]';

%% Parse the .ROI data
for i = 1:sz(1)
    x = char(data(i,1));
    x = regexprep(x,'†††','††{0.0, 0.0}††'); % Tag new traces with 0.0 point
    match = regexp(x,form,'match');
    [~,m] = size(match);
    y = cell(3,m);
    for j = 1:m % Clean up the data points
        y(1,j) = match(1,j);
        z = regexp(match(1,j),xPoint,'match');
        y(2,j) = regexprep(z{:},point,'');
        z = regexp(match(1,j),yPoint,'match');
        y(3,j) = regexprep(z{:},point,'');
        a(count,1) = str2double(y(2,j));
        a(count,2) = str2double(y(3,j));
        if a(count,1) == 0 && a(count,2) == 0
            trace = trace+1;
        end
        a(count,3) = trace;
        count = count+1;
    end
end

%% Remove Trace Tags
[n,~] = size(a);
i = 1;
while i<n+1
    if a(i,1) == 0 && a(i,2) == 0
        a(i,:) = [];
        [n,~] = size(a);
    else
        i = i+1;
    end
end

%% Interpolate and Create Masks
d = [];
f = [];
aOriginal = a;
res = 2048; % Mask resolution
for k = 1:trace-1
    b = a(a(:,3) == k,:); % Work with one trace at a time
    c = V_interpolate(b,5,5);
    f = cat(1,f,c);
    e = (c(:,1:2)-80).*5;
    d = cat(1,d,e);
    mask(:,:,k) = poly2mask(e(:,1),e(:,2),res,res);
    Parameters  = regionprops(mask(:,:,k),'Centroid','Area','MajorAxisLength');
    center(k,:) = Parameters.Centroid;
    area(k) = Parameters.Area;
    MAL(k) = Parameters.MajorAxisLength;
    % imshow(mask(:,:,k));
end

%% Find Labels for Each Trace
d(:,3) = f(:,3);
[n,~] = size(d);
d = num2cell(d);
idCode = FindDataLabels(filename);
for i=1:n
    j = cell2mat(d(i,3));
    if j> size(idCode)
        break;
    end
    d{i,4} = idCode{j};
end