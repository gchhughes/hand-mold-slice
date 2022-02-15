function [ID] = FindDataLabels(fileName)
%fileName = 'C:\Users\jakep\Documents\School\PhD\Mold vs. No Mold\mold non mold data, 09-25-19\Roh Si\Seg\WM10.roi';
data = importdata(fileName);
ID = [];
n = size(data);
y = '';
for i = 1:n(1)
    y = [y,char(data(i))];
end
traceEnd = regexpi(y,'†††');
tzLoc = regexpi(y,'Tz');
pzLoc = regexpi(y,'Pz');
prostateLoc = regexpi(y,'prostate');
areaLoc = regexpi(y,'Area');
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
            ID{i} = 'prostate';
            traceEnd(i) - x;
            break
        elseif x == pzLoc
            ID{i} = 'PZ';
            traceEnd(i) - x;
            break
        elseif x == tzLoc
            ID{i} = 'TZ';
            traceEnd(i) - x;
            break
        elseif strcmp(y(x),'1') || strcmp(y(x),'2') || strcmp(y(x),'3') || strcmp(y(x),'4') || strcmp(y(x),'5') || strcmp(y(x),'6') || strcmp(y(x),'7') || strcmp(y(x),'8') || strcmp(y(x),'9')
            ID{i} = y(x);
            traceEnd(i) - x;
            break
        end
        x = x+1;
    end
end
pass = false;
n = size(ID);
for i = 1:n(2)
    if strcmp(ID{i},'prostate')
        pass = true;
    end
end
if pass == false
    ID = [];
end
ID;
