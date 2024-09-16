function [rank,U, t] = arnoldi_rank_init(tns)
%ARNOLDI_RANK_INIT Summary of this function goes here
%   Detailed explanation goes here
% INPUT PARAMETER
%   tns - tensor or sparse tensor (tensor toolbox format)
% OUTPUT PARAMETERS
%   rank    - scalar, estimated rank of tns
%   U       - CP model initialization
%   t       - time for estimation and initialization

% basic setup
k = max(size(tns));
modes = ndimes(tns);
cond_nums = zeros(k, modes);
ranks = zeros(modes,1);

% construct overestimated krylov subspace
U = 
end

