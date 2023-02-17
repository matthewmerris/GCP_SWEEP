function [rank,factors] = estRank(X)
%ESTRANK Provides a CP-rank estimate as well as a K-tensor initialization
%        for some tensor X
%   Utilizes singular value thresholding on a series of modal unfoldings of
%   a tensor to arrive at an estimate of the tensor's CP-rank.
%   Optional: Initialize a k-tensor using the left singular vectors from SVDs 
%   of modal unfoldings using the estimated CP-rank.
%   TEMPORARY MODIFICATION: ktensor() is misbehaving, changing to return a 
%                           cell array of factor matrices for the time
%                           being.

% CAPTURE BASIC INFO: number of modes, dimension of minimal mode
rank = 1;
modes = ndims(X);
min_dim = min(size(X));
% disp('Modes: ' + modes)

% identify the modal unfolding with the largest number of singular values
min_k = floor(min_dim/modes);
for i = 1:modes
    [~,S,~,flag] = svt(double(tenmat(X,i)), 'method', 'succession',...
                        'k', min_k, 'lambda', 1e-5, 'incre', 2);
    if flag
        disp('Eigs not converged!')
    end
    
    if nnz(S) > rank
        rank = nnz(S);
    end
end

% use rank to collect left singular vectors
factors = cell(1,modes);
for i = 1:modes
    [U,~,~,flag] = svt(double(tenmat(X,i)), 'k', rank);
    if flag
        disp('Eigs not converged!')
    end
    factors{i} = U;
end

% kten = ktensor(ones(rank,1),factors);
    
end

