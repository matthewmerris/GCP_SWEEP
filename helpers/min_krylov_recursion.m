function [U,H] = min_krylov_recursion(A, k)
%MIN_KRYLOV_RECURSION Summary of this function goes here
%   Detailed explanation goes here
n = ndims(A);
sz = size(A);
% initialize cell arrays for each mode's factor matrix and Hessian
U = cell(n,1); 
H = cell(n,1);

% populate the first column of the first (n-1) factor matrices w/ 
% uniform random vectors
for idx = 1:n
    U{idx} = zeros(sz(idx),k);
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
        u = ttv(A,us, modes);
        u = u / norm(u);
    end
    U{idx}(:,1) = u;
end

% Ready to cycle
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
        w = ttv(A, us, modes);
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
        U{jdx}(:,kdx) = w / H{jdx}(kdx + 1, kdx);
    end
end
% 
end

