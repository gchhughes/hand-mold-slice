function [ vector ] = vectorCircle( circleNum )
%Generates a list of normalized vectors, centered around zero, that trace
%the path fo a circle. CircleNum, the number of desired vectors, MUST be
%divisible by 4. Funny enough, this is also in practice a regular 2D polygon
%generator.

%Set the x's
vector(1:circleNum/4-1,1) = 1;
vector(circleNum/4+1:circleNum/4*3-1,1) = -1;
vector(circleNum/4*3+1:circleNum,1) = 1;

%Fill in the y's
for i = 1:circleNum
    vector(i,2) = tan(2*pi/circleNum*i)*vector(i,1);
end

%Fix the y's that were positive and negative infinite
vector(circleNum/4,2) = 1;
vector(circleNum/4*3,2) = -1;

for i = 1:circleNum
    vector(i,1:2) = vector(i,1:2)/norm(vector(i,1:2));
end

end

