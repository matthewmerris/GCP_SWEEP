function rmsErr = rms_err(X,M)
%RMSE calculates the root mean squared error 
M1 = full(M);
num_entries = numel(X);
numerator = norm(X-M1)^2;
rmsErr = sqrt(numerator/num_entries);
end

