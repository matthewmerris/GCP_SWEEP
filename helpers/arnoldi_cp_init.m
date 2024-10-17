function factors = arnoldi_cp_init(tns,k)
%CP_INIT_ARNOLDI Summary of this function goes here
%   Detailed explanation goes here
modes = ndims(tns);
factors = cell(modes,1);

for i = 1:modes
    % form A depending on tns (tensor or sptensor)
    if(isa(tns,'tensor'))
        tmp = unfold(tns, i);
        A = tmp * tmp';
        [m,~] = size(A);
    elseif(isa(tns,'sptensor'))
        A = sptenmat(tns, i, 'fc');
        m = size(A,1);
    end

    % call the arnoldi constructor
    q1 = rand(m,1);
    if(isa(tns,'sptensor'))
        [factor,~] = arnoldi_constructor_sparse(A, q1, k);
    else
        [factor,~] = arnoldi_constructor(A, q1, k);
    end
    
    % store factor matrix
    factors{i} = factor;
end

end

