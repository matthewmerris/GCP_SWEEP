function [rank] = simpleRankEst(X)
%SIMPLERANKEST rudimentary tensor rank estimation based SVDs of
%mode-centric unfoldings of a tensor X.
%   Brute force approach, unfolds a tensor in a specific mode, transposes
%   the resulting matrix and computes the number of singular values above a
%   threshold.  This approach will be improved by incorporating singular
%   value thresholding (https://github.com/Hua-Zhou/svt)
rank = 1;
threshold = 0.0000000001;
for i=1:ndims(X)
    X_mat = double(tenmat(X,i))';
    S = svd(X_mat,'econ');
    tmp_rank = nnz(S>threshold);
    if tmp_rank > rank
        rank = tmp_rank;
    end
end

