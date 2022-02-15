function [ d ] = point_to_line( pt, v1, v2 )
%Computes distance between the point (1st argument) and two vertices on a
%line, e.g. v1 and v2
      a = v1 - v2;
      b = pt - v2;
      d = norm(cross(a,b)) / norm(a);
end

