function [Q,H] = arnoldi_constructor(A,k_max,q1)
%ARNOLDI_CONSTRUCTOR Summary of this function goes here
%   Detailed explanation goes here
n = length(A);
Q = zeros(n, k_max);
q1 = q1 / norm(q1);
Q(:,1) = q1;
H = zeros(min(k_max + 1, k_max), n);

for k = 1:k_max
    z = A * Q(:,k);
    for i = 1:k
        H(i,k) = Q(:,i)' * z;
        z = z - H(i,k) * Q(:,i);
    end
    if k < n
        H(k+1,k) = norm(z);
        if H(k+1,k) ~= 0
            Q(:,k+1) = z / H(k+1,k);
        end
    end
end

