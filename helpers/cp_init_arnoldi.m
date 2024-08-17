function factors = cp_init_arnoldi(tns,rank)
%CP_INIT_ARNOLDI Summary of this function goes here
%   Detailed explanation goes here
modes = ndims(tns);
factors = cell(modes,1);

for i=1:modes
    tmp = unfold(tns,i);
    [m,~] = size(tmp);
    q1 = rand(m,1);
    tmp1 = tmp * tmp';
    [factor,~] = arnoldi_constructor(tmp1, q1, rank);
    factors{i} = factor;
end


end

