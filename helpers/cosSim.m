function [cos_sim] = cosSim(X,M,modes)
%COSSIM returns cosine similarity of two tensors
%   vectorize tensors X & M and calculate cosine
%   similarity.
x = double(tenmat(X,1:modes));
y = double(tenmat(M,1:modes));
xy = dot(x,y);
x_nrm = norm(x);
y_nrm = norm(y);
xy_nrm = x_nrm * y_nrm;
cos_sim = xy/xy_nrm;
end

