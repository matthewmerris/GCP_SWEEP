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
        U{idx}(:,1) = u;
    end
end

% calculate first column of n-th mode factor matrix
us = cell(1,n - 1);
modes = zeros(1,num_modes - 1);
for idx = 1:(n-1)
%     vecs.append(U{idx}(:,1));
    us{1,idx} = U{idx}(:,1);
    modes(1,idx) = idx;
end
u = ttv(tns,us, modes);
% normalize and store
u = u / norm(u);
U{n}(:,1) = u;

% Ready to cycle


outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

