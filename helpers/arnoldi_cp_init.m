function factors = arnoldi_cp_init(tns,k, vec_gen)
%CP_INIT_ARNOLDI Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3
    vec_gen = "rand";
end

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
    
    % generate initial vector
    if strcmp(vec_gen, "randn")
        q1 = randn(m,1);
    elseif strcmp(vec_gen, "rand")
        q1 = rand(m,1);
    else
        sprintf("Type: %s not supported, uniform random initialization empoloyed.", vec_gen)
        q1 = rand(m,1);
    end
    
    % call the arnoldi constructor
    if(isa(tns,'sptensor'))
        [factor,~] = arnoldi_constructor_sparse(A, q1, k);
    else
        [factor,~] = arnoldi_constructor(A, q1, k);
    end
    
    % store factor matrix
    factors{i} = factor;
end

end

