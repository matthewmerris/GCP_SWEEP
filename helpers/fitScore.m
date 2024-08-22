function result = fitScore(X,M)
%FITSCORE Summary of this function goes here
%   Detailed explanation goes here
% result = abs(1 - normDiff(M,X)/norm(X));
n = ndims(X);
U_mttkrp = mttkrp(X, M.U, n);
iprod = sum(sum(M.U{n} .* U_mttkrp) .* M.lambda');
normX = norm(X);
if normX == 0
    result = norm(M)^2 - 2 * iprod;
else
    normRes = sqrt(normX^2 + norm(M)^2 - 2 * iprod);
    result = 1 - (normRes / normX);
end

% result = 1 - norm(X - full(M))/norm(X);
end

