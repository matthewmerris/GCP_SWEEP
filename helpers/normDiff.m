function result = normDiff(X,M)
%NORMTRICK calculate Forbenius norm of the difference of tensors X & M
%   leverages tensor toolbox optimizations to calculate the norm of the
%   difference between two tensors of different types(ktensor, sptensor, 
%   etc.  This is helpful for handling very large, sparse tensors, i.e. 
%   FROSTT.io style tensors
result = sqrt(norm(X)^2 - 2*innerprod(X,M) + norm(M)^2);
end


