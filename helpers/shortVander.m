function A = ShortVander(x, n)
%   calculate a truncated Vandermonde matrix, x rows & n cols
x = x(:);  % Column vector
A = ones(length(x), n);
for i = 2:n
  A(:, i) = x .* A(:, i-1);  % [EDITED, Thanks Steven]
end

