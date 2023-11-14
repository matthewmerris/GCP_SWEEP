function [angles] = subspaceAngles(X,M)
%SUBSPACEANGLES Summary of this function goes here
%   Detailed explanation goes here
num_modes = length(size(X));
M_full = full(M);
angles = zeros(num_modes,1);

for i = 1:num_modes
    % matricize tensors and calculate angle between subspaces
    angles(i) = subspace(unfold(X,i), unfold(M_full,i));
    %angles(i) = subspace(double(tenmat(X,i)), double(tenmat(M_full,i)));

end

