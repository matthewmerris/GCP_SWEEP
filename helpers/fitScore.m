function result = fitScore(X,M)
%FITSCORE Summary of this function goes here
%   Detailed explanation goes here
result = abs(1 - normDiff(M,X)/norm(X));
end

