function factors = cp_init_arnoldi(tns,rank)
%CP_INIT_ARNOLDI Summary of this function goes here
%   Detailed explanation goes here
modes = ndims(tns);
factors = cell(modes,1);

if(isa(tns,'tensor'))
    for i=1:modes
        tmp = unfold(tns,i);
        [m,~] = size(tmp);
        q1 = rand(m,1);
        tmp1 = tmp * tmp';
        [factor,~] = arnoldi_constructor(tmp1, q1, rank);
        factors{i} = factor;
    end
elseif(isa(tns,'sptensor'))
    for i=1:modes
        % reshape tns to order-2 for the i-th mode
        % form AA^T
        % call the arnoldi constructor
        % store factor matrix
    end
end

end

