function factors = cp_init_arnoldi(tns,k)
%CP_INIT_ARNOLDI Summary of this function goes here
%   Detailed explanation goes here
modes = ndims(tns);
factors = cell(modes,1);

for i = 1:modes
    % form A depending on tns (tensor or sptensor)
    if(isa(tns,'tensor'))
        tmp = unfold(tns, i);
        A = tmp * tmp';
    elseif(isa(tns,'sptensor'))
        tmp = double(sptenmat(tns, i, 'fc'));
        A = full(tmp * tmp');
    end
    [m,~] = size(A);
    q1 = rand(m,1);
    % call the arnoldi constructor
    [factor,~] = arnoldi_constructor(A, q1, k);
    % store factor matrix
    factors{i} = factor;
end

end

