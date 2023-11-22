%% load the naive baseline data
load("5-gens_100-tens_100-init_5-losses_17-Nov-2023 21:09:59.mat");

% N-way arrays: fits, cossims, corcondias, times 
% Index mapping:    generators x tensor x run x loss function (5 x 100 x 100 x 5)

% N-way cell arrays: angles
% Index mapping:    generators x tensor x run x loss function

% N-way cell arrays: best_fits, best_cossims, best_times, best_corcondias
% Index mapping:    generators x tensor x loss function x [value, model, model info, run number]
gens = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
%% Plot best results for each tensor for every loss
% rand_fits = cell2mat(squeeze(best_fits(1,:,:,1)));
rand_fits = cell2mat(best_fits(1,:,1,1));

%% Brute force best metrics
rand_fits = zeros(100,5);
rand_cossims = zeros(100,5);
rand_corcondias = zeros(100,5);
rand_times = zeros(100,5);

for j = 1:5
    for i = 1:100
        rand_fits(i,j) = max(fits(1,i,:,j));
        rand_cossims(i,j) =  max(cossims(1,i,:,j));
        rand_corcondias(i,j) = max(corcondias(1,i,:,j));
        rand_times(i,j) = min(times(1,i,:,j));
    end
end

randn_fits = zeros(100,5);
randn_cossims = zeros(100,5);
randn_corcondias = zeros(100,5);
randn_times = zeros(100,5);

for j = 1:5
    for i = 1:100
        randn_fits(i,j) = max(fits(2,i,:,j));
        randn_cossims(i,j) =  max(cossims(2,i,:,j));
        randn_corcondias(i,j) = max(corcondias(2,i,:,j));
        randn_times(i,j) = min(times(2,i,:,j));
    end
end

rayleigh_fits = zeros(100,5);
rayleigh_cossims = zeros(100,5);
rayleigh_corcondias = zeros(100,5);
rayleigh_times = zeros(100,5);

for j = 1:5
    for i = 1:100
        rayleigh_fits(i,j) = max(fits(3,i,:,j));
        rayleigh_cossims(i,j) =  max(cossims(3,i,:,j));
        rayleigh_corcondias(i,j) = max(corcondias(3,i,:,j));
        rayleigh_times(i,j) = min(times(3,i,:,j));
    end
end

beta_fits = zeros(100,5);
beta_cossims = zeros(100,5);
beta_corcondias = zeros(100,5);
beta_times = zeros(100,5);

for j = 1:5
    for i = 1:100
        beta_fits(i,j) = max(fits(4,i,:,j));
        beta_cossims(i,j) =  max(cossims(4,i,:,j));
        beta_corcondias(i,j) = max(corcondias(4,i,:,j));
        beta_times(i,j) = min(times(4,i,:,j));
    end
end

gamma_fits = zeros(100,5);
gamma_cossims = zeros(100,5);
gamma_corcondias = zeros(100,5);
gamma_times = zeros(100,5);

for j = 1:5
    for i = 1:100
        gamma_fits(i,j) = max(fits(5,i,:,j));
        gamma_cossims(i,j) =  max(cossims(5,i,:,j));
        gamma_corcondias(i,j) = max(corcondias(5,i,:,j));
        gamma_times(i,j) = min(times(5,i,:,j));
    end
end