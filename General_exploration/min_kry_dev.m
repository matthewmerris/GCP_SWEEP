%% generate a tensor
sz = [20 25 30];
nc = 5;

prb = create_problem('Size', sz, 'Num_Factors', nc, ...
    'Factor_Generator', 'stochastic');
tns = prb.Data;

%% gather relavent details for construction
num_modes = ndims(tns);
dimensions = size(tns);
U = cell(num_modes,1);
H = cell(num_modes,1);
k = nc;

for idx = 1:num_modes
    U{idx} = zeros(dimensions(idx),k);
    H{idx} = zeros(k,k);
    % populate 1st column of the first (num_modes - 1) modes
    % with rand
    if idx ~= num_modes
        u = rand(dimensions(idx),1);
        U{idx}(:,1) = u;
    end
end


%%
% tmp = tns;
vecs = cell(num_modes - 1, 1);
mode_mult = zeros(num_modes - 1, 1);
for idx = 1:(num_modes-1)
    vecs{idx} = squeeze(U{idx}(:,1));
    mode_mult(idx) = idx;
end
tmp = ttv(tns,vecs, mode_mult);
size(U{1}(:,1))

%%
vecs = {rand(sz(1),1), rand(sz(2),1)};
mds = [1 2];
tmp = ttv(tns, vecs, mds);

size(tmp)