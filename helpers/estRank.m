function [rank,kten] = estRank(X)
%ESTRANK Provides a CP-rank estimate as well as a K-tensor initialization
%        for some tensor X
%   Utilizes singular value thresholding on a series of modal unfoldings of
%   a tensor to arrive at an estimate of the tensor's CP-rank.
%   Optional: Initialize a k-tensor using the left singular vectors from SVDs 
%   of modal unfoldings using the estimated CP-rank.
rank = 1;
modes = ndims(X);

% identify the modal unfolding with the largest number of singular values

for i = 1:modes
    [~,S,~,flag] = svt(double(tenmat(X,i)), 'method', 'succession');
    if flag
        disp('Eigs not converged!')
    end
    
    if nnz(S) > rank
        rank = nnz(S);
    end
end

% use rank to collect left singular vectors
factors = cell(modes);
for i = 1:modes
    [U,~,~,flag] = svt(double(tenmat(X,i)), 'k', rank);
    if flag
        disp('Eigs not converged!')
    end
    factors{i} = U;
end

kten = ktensor(factors);
    
end

