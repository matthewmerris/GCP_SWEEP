function rms_err = rmse(X,M)
%RMSE calculates the root mean squared error 
M1 = full(M);
num_entries = numel(X);
numerator = norm(X-M1)^2;
rms_err = sqrt(numerator/num_entries);
end

