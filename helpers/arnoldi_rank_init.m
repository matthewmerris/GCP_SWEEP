function [ranks,U, t] = arnoldi_rank_init(tns)
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
modes = ndims(tns);
cond_nums = zeros(k, modes);
ranks = zeros(modes,1);

% construct overestimated krylov subspace and calculate condition numbers
t_strt = tic;
U = arnoldi_cp_init(tns, k);
for jdx = 1:modes
    for idx = 1:k
        cond_nums(idx, jdx) = cond(U{jdx}(:, 1:idx));
    end
end

for kdx = 1:modes
    for jdx = 3:k
        tmp = diff(cond_nums(1:jdx,kdx));
        tl_diff = cond_nums(jdx,kdx) - cond_nums(1,kdx);
        tmp = tmp ./ tl_diff;
        idx = 2;
        while sum(tmp(1:idx)) < 0.06
            if idx > length(tmp)
                break;
            end
            idx = idx + 1;
        end
        ranks(kdx,1) = idx - 1;
%         for idx = 4:length(tmp)
%             if sum(tmp(1:idx)) > 0.05
%                 ranks(kdx,1) = idx - 1;
%                 break;
%             end
%         end
%         if tmp(end) >= 0.75
%             ranks(kdx,1) = jdx;
%         end
    end
end
t = toc(t_strt);
end

