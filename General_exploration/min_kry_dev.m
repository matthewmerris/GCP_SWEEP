%% generate a tensor
sz0 = [20 25 30];
nc = 5;

prb = create_problem('Size', sz0, 'Num_Factors', nc, ...
    'Factor_Generator', 'stochastic');
tns = prb.Data;

%% gather relavent details for construction
n = ndims(tns);
sz = size(tns);
U = cell(n,1);
H = cell(n,1);
k = nc;

for idx = 1:n
    U{idx} = zeros(sz(idx),k + 1);
    H{idx} = zeros(k+1,k);
    % populate 1st column of the first (num_modes - 1) modes
    % with rand
    if idx ~= n
        u = rand(sz(idx),1);
        % normalize and store
        u = u / norm(u);
    else
        us = cell(1,n - 1);
        modes = zeros(1,n - 1);
        for jdx = 1:(n-1)
        %     vecs.append(U{idx}(:,1));
            us{1,jdx} = U{jdx}(:,1);
            modes(1,jdx) = jdx;
        end
        u = ttv(tns,us, modes);
        u = u / norm(u);
    end
    U{idx}(:,1) = u;
end

for kdx = 2:k           % kdx-th column
    for jdx = 1:n       % jdx-th mode
        us = cell(1, n - 1);
        modes = zeros(1,n -1);
        for i = 1:n
            if i < jdx
                us{1,i} = U{i}(:, kdx - 1);
                modes(1,i) = i;
            elseif i > jdx
                us{1, i - 1} = U{i}(:, kdx - 1);
                modes(1, i - 1) = i;
            end
        end
        w = ttv(tns, us, modes);
        for idx = 1:kdx % orthogonalization loop
%             foo = U{jdx}(:,idx);
%             bar = double(w);
            H{jdx}(idx,kdx) = U{jdx}(:,idx)' * double(w);
            w = double(w) - H{jdx}(idx,kdx) * U{jdx}(:,idx);
        end
        H{jdx}(kdx + 1, kdx) = norm(w);
        if H{jdx}(kdx + 1, kdx) == 0
            break;
        end
        % store in jdx-th mode basis
        U{jdx}(:,kdx + 1) = w / H(kdx + 1, kdx);
    end
end


%%
% tmp = tns;
us = cell(1,num_modes - 1);
modes = zeros(1,num_modes - 1);
for idx = 1:(num_modes-1)
%     vecs.append(U{idx}(:,1));
    us{1,idx} = U{idx}(:,1);
    modes(1,idx) = idx;
end

tmp = ttv(tns,us, modes);
% size(U{1}(:,1))

%%
vecs_1 = {rand(sz(1),1), rand(sz(2),1)};
mds = [1 2];
tmp = ttv(tns, vecs, mds);

size(tmp)
size(rand(sz(1),1))
size(U{1}(:,1))