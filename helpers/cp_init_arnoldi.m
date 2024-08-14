function factors = cp_init_arnoldi(tns,rank)
%CP_INIT_ARNOLDI Summary of this function goes here
%   Detailed explanation goes here
modes = ndims(tns);
factors = [];

for i=1:modes
    tmp = unfold(tns,i);
    factor = arnoldi_constructor(tmp, rank);
    factors(i) = factor;
end


end

