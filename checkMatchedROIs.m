%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   checkMatchedROIs                                                     %
%   CASIT                                                                %
%   Author: Jake Pensa                                                   %
%   Date:   01/18/2022                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [key] = checkMatchedROIs(data)
key = ones(1,6);
if isempty(data.mrProstate) || isempty(data.wmProstate)
    key(1) = 0;
end
if isempty(data.mrTz) || isempty(data.wmTz)
    key(2) = 0;
end
if isempty(data.mrPz) || isempty(data.wmPz)
    key(3) = 0;
end
if isempty(data.mrTumor1) || isempty(data.wmTumor1)
    key(4) = 0;
end
if isempty(data.mrTumor2) || isempty(data.wmTumor2)
     key(5) = 0;
end
if isempty(data.mrTumor3) || isempty(data.wmTumor3)
    key(6) = 0;
end

