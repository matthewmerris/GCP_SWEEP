function [V,H] = arnoldi_constructor(A,b,k)
%ARNOLDI_CONSTRUCTOR Summary of this function goes here
%   Detailed explanation goes here
[m,~] = size(A);
V = zeros(m, k+1);
H = zeros(k+1, k);

V(:,1) = b / norm(b); % normalize and store initial col vector for basis

% perform Arnoldi iteration
for j = 1:k
    w = A * V(:,j); % multiply A & current col vec in the basis
    for i = 1:j
        % orthogonalize w against all vectors in V
        H(i,j) = V(:,i)' * w;
        w = w - H(i,j) * V(:,i);
    end
    H(j+1,j) = norm(w); % store norm of the residual
    if H(j+1, j) == 0
        break;
    end

    % normalize residual vector and store in basis
    V(:, j+1) = w / H(j+1, j);
end
V = V(:, 1:k);
end

