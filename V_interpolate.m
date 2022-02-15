function [ resultPoints, CC ] = V_interpolate(V0, resultCount, degree)
%Performs Vandermonde interpolation on the input V0, which is a
%chronological list of points representing a surface. Assumes evenly
%weighted points, sampled resultCount times between each point in V0. Can
%perform either third degree or 5th degree polynomial interpolations.

if degree == 3
    
    M = [1 0 0 0
        1 1 1 1
        1 2 4 8
        1 3 9 27];   %Default matrix for equally weighted point
    
    V0_count = size(V0);
    
    V0= vertcat(V0,V0,V0); %Loop the matrix V0 once
    
    for i = 1:(V0_count(1) + 3)  %Next,for all desired results
        for h = 1:size(V0,2)             %For all three dimensions
            
            y = [V0(i,h); V0(i+1,h); V0(i+2,h); V0(i+3,h)];   %Values of y at each point in region of interest
            
            CC(i,h,1:4) = M\y;   %Compute coefficients for region i, dimension h, of equation: y = C(1) + C(2)*t^2 + C(3)*t^3 + C(4)*t^4
        end
    end
    
    for i = 1:(resultCount*V0_count+1)   %For every desired result
        result(i) = 1 + (1/resultCount)*i;
        fres = floor(result(i));
        
        for h = 1:size(V0,2)
            resultPoints(i,h) = CC(fres,h,1) + CC(fres,h,2)*(result(i)-fres) + CC(fres,h,3)*(result(i)-fres)^2 + CC(fres,h,4)*(result(i)-fres)^3;
        end
    end
    
elseif degree == 5
    
    M = [1 0 0 0 0 0
         1 1 1 1 1 1
         1 2 4 8 16 32
         1 3 9 27 81 243
         1 4 16 64 256 1024
         1 5 25 125 625 3125];   %Default matrix for equally weighted point
    
    V0_count = size(V0);
    
    V0= vertcat(V0,V0,V0); %Loop the matrix V0 once
    
    for i = 1:(V0_count(1) + 5)  %Next,for all desired results
        for h = 1:size(V0,2)             %For all three dimensions
            
            y = [V0(i,h); V0(i+1,h); V0(i+2,h); V0(i+3,h); V0(i+4,h); V0(i+5,h)];   %Values of y at each point in region of interest
            
            CC(i,h,1:6) = M\y;   %Compute coefficients for region i, dimension h, of equation: y = C(1) + C(2)*t^2 + C(3)*t^3 + C(4)*t^4
        end
    end
    
    for i = 1:(resultCount*V0_count+1)   %For every desired result
        result(i) = 1 + (1/resultCount)*i;
        fres = floor(result(i));
        offset = 2;
        
        for h = 1:size(V0,2)
            resultPoints(i,h) = CC(fres,h,1) + CC(fres,h,2)*(result(i)-fres+offset) + CC(fres,h,3)*(result(i)-fres+offset)^2 + CC(fres,h,4)*(result(i)-fres+offset)^3 + CC(fres,h,5)*(result(i)-fres+offset)^4 + CC(fres,h,6)*(result(i)-fres+offset)^5;
        end
    end 
    
else
    'degree must be 3 or 5'
end

resultPoint = resultPoints(1:end-1,1:end);

%Graph Results in 2D
%{
figure
plot(V0(1:end,1),V0(1:end,2),'Color','r','Marker','x','Linestyle','none')
hold on
plot(resultPoints(1:end,1),resultPoints(1:end,2),'Color','g')
%}


end

