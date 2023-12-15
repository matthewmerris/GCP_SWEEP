%% load the naive baseline data
%load("5-gens_100-tens_100-init_5-losses_17-Nov-2023 21:09:59.mat");
load("5-gens_100-tens_100-init_5-losses_05-Dec-2023 21:11:38.mat");
% N-way arrays: fits, cossims, corcondias, times 
% Index mapping:    generators x tensor x run x loss function (5 x 100 x 100 x 5)

% N-way cell arrays: angles
% Index mapping:    generators x tensor x run x loss function

% N-way cell arrays: best_fits, best_cossims, best_times, best_corcondias
% Index mapping:    generators x tensor x loss function x [value, model, model info, run number]
gens = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
%% Plot best results for each tensor for every loss
% rand_fits = cell2mat(squeeze(best_fits(1,:,:,1)));
%  rand_fits = cell2mat(best_fits(1,:,1,1));
num_runs = 100;
num_gens = length(gens);
num_losses = length(losses);
num_tensors = 100;

%% Brute force best metrics
rand_fits = zeros(100,5);
rand_cossims = zeros(100,5);
rand_corcondias = zeros(100,5);
rand_times = zeros(100,5);

for j = 1:num_losses
    for i = 1:num_runs
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

for j = 1:num_losses
    for i = 1:num_runs
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

for j = 1:num_losses
    for i = 1:num_runs
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

for j = 1:num_losses
    for i = 1:num_runs
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

for j = 1:num_losses
    for i = 1:num_runs
        gamma_fits(i,j) = max(fits(5,i,:,j));
        gamma_cossims(i,j) =  max(cossims(5,i,:,j));
        gamma_corcondias(i,j) = max(corcondias(5,i,:,j));
        gamma_times(i,j) = min(times(5,i,:,j));
    end
end

%% visualize best results

% mean and std of best results for each loss function

% rand generator
isOut = isoutlier(rand_fits);
rand_fits_clean = rand_fits;
rand_fits_clean(isOut) = NaN;

isOut = isoutlier(rand_cossims);
rand_cossims_clean = rand_cossims;
rand_cossims_clean(isOut) = NaN;

isOut = isoutlier(rand_corcondias);
rand_corcondias_clean = rand_corcondias;
rand_corcondias_clean(isOut) = NaN;

isOut = isoutlier(rand_times);
rand_times_clean = rand_times;
rand_times_clean(isOut) = NaN;

figure();
sgtitle('Rand Generator');
ax(1) = subplot(1,4,1);
boxplot(ax(1),rand_fits_clean, 'Labels', losses);
title(ax(1), 'Fit Score');
grid(ax(1),'on');

ax(2) = subplot(1,4,2);
boxplot(ax(2),rand_cossims_clean, 'Labels', losses);
title(ax(2), 'Cosign Similarity');
grid(ax(2),'on');

ax(3) = subplot(1,4,3);
boxplot(ax(3),rand_corcondias_clean, 'Labels', losses);
title(ax(3), 'Corcondia Score');
grid(ax(3),'on');

ax(4) = subplot(1,4,4);
boxplot(ax(4),rand_times_clean, 'Labels', losses);
title(ax(4), 'Time');
grid(ax(4),'on');

% randn generator
isOut = isoutlier(randn_fits);
randn_fits_clean = randn_fits;
randn_fits_clean(isOut) = NaN;

isOut = isoutlier(randn_cossims);
randn_cossims_clean = randn_cossims;
randn_cossims_clean(isOut) = NaN;

isOut = isoutlier(randn_corcondias);
randn_corcondias_clean = randn_corcondias;
randn_corcondias_clean(isOut) = NaN;

isOut = isoutlier(randn_times);
randn_times_clean = randn_times;
randn_times_clean(isOut) = NaN;

figure();
sgtitle('Randn Generator');
ax(1) = subplot(1,4,1);
boxplot(ax(1),randn_fits_clean, 'Labels', losses);
title(ax(1), 'Fit Score');
grid(ax(1),'on');

ax(2) = subplot(1,4,2);
boxplot(ax(2),randn_cossims_clean, 'Labels', losses);
title(ax(2), 'Cosign Similarity');
grid(ax(2),'on');

ax(3) = subplot(1,4,3);
boxplot(ax(3),randn_corcondias_clean, 'Labels', losses);
title(ax(3), 'Corcondia Score');
grid(ax(3),'on');

ax(4) = subplot(1,4,4);
boxplot(ax(4),randn_times_clean, 'Labels', losses);
title(ax(4), 'Time');
grid(ax(4),'on');

% rayleigh generator
isOut = isoutlier(rayleigh_fits);
rayleigh_fits_clean = rayleigh_fits;
rayleigh_fits_clean(isOut) = NaN;

isOut = isoutlier(rayleigh_cossims);
rayleigh_cossims_clean = rayleigh_cossims;
rayleigh_cossims_clean(isOut) = NaN;

isOut = isoutlier(rayleigh_corcondias);
rayleigh_corcondias_clean = rayleigh_corcondias;
rayleigh_corcondias_clean(isOut) = NaN;

isOut = isoutlier(rayleigh_times);
rayleigh_times_clean = rayleigh_times;
rayleigh_times_clean(isOut) = NaN;

figure();
sgtitle('Rayleigh Generator');
ax(1) = subplot(1,4,1);
boxplot(ax(1),rayleigh_fits_clean, 'Labels', losses);
title(ax(1), 'Fit Score');
grid(ax(1),'on');

ax(2) = subplot(1,4,2);
boxplot(ax(2),rayleigh_cossims_clean, 'Labels', losses);
title(ax(2), 'Cosign Similarity');
grid(ax(2),'on');

ax(3) = subplot(1,4,3);
boxplot(ax(3),rayleigh_corcondias_clean, 'Labels', losses);
title(ax(3), 'Corcondia Score');
grid(ax(3),'on');

ax(4) = subplot(1,4,4);
boxplot(ax(4),rayleigh_times_clean, 'Labels', losses);
title(ax(4), 'Time');
grid(ax(4),'on');

% beta generator
isOut = isoutlier(beta_fits);
beta_fits_clean = beta_fits;
beta_fits_clean(isOut) = NaN;

isOut = isoutlier(beta_cossims);
beta_cossims_clean = beta_cossims;
beta_cossims_clean(isOut) = NaN;

isOut = isoutlier(beta_corcondias);
beta_corcondias_clean = beta_corcondias;
beta_corcondias_clean(isOut) = NaN;

isOut = isoutlier(beta_times);
beta_times_clean = beta_times;
beta_times_clean(isOut) = NaN;

figure();
sgtitle('Beta Generator');
ax(1) = subplot(1,4,1);
boxplot(ax(1),beta_fits_clean, 'Labels', losses);
title(ax(1), 'Fit Score');
grid(ax(1),'on');

ax(2) = subplot(1,4,2);
boxplot(ax(2),beta_cossims_clean, 'Labels', losses);
title(ax(2), 'Cosign Similarity');
grid(ax(2),'on');

ax(3) = subplot(1,4,3);
boxplot(ax(3),beta_corcondias_clean, 'Labels', losses);
title(ax(3), 'Corcondia Score');
grid(ax(3),'on');

ax(4) = subplot(1,4,4);
boxplot(ax(4),beta_times_clean, 'Labels', losses);
title(ax(4), 'Time');
grid(ax(4),'on');

% gamma generator
isOut = isoutlier(gamma_fits);
gamma_fits_clean = gamma_fits;
gamma_fits_clean(isOut) = NaN;

isOut = isoutlier(gamma_cossims);
gamma_cossims_clean = gamma_cossims;
gamma_cossims_clean(isOut) = NaN;

isOut = isoutlier(gamma_corcondias);
gamma_corcondias_clean = gamma_corcondias;
gamma_corcondias_clean(isOut) = NaN;

isOut = isoutlier(gamma_times);
gamma_times_clean = gamma_times;
gamma_times_clean(isOut) = NaN;

figure();
sgtitle('Gamma Generator');
ax(1) = subplot(1,4,1);
boxplot(ax(1),gamma_fits_clean, 'Labels', losses);
title(ax(1), 'Fit Score');
grid(ax(1),'on');

ax(2) = subplot(1,4,2);
boxplot(ax(2),gamma_cossims_clean, 'Labels', losses);
title(ax(2), 'Cosign Similarity');
grid(ax(2),'on');

ax(3) = subplot(1,4,3);
boxplot(ax(3),gamma_corcondias_clean, 'Labels', losses);
title(ax(3), 'Corcondia Score');
grid(ax(3),'on');

ax(4) = subplot(1,4,4);
boxplot(ax(4),gamma_times_clean, 'Labels', losses);
title(ax(4), 'Time');
grid(ax(4),'on');

%% Subspace angles visualization
% Calculate SUM of subspace angles
angles_sums_rand = zeros(num_tensors,num_runs,num_losses);
angles_sums_randn = zeros(num_tensors,num_runs,num_losses);
angles_sums_rayleigh = zeros(num_tensors,num_runs,num_losses);
angles_sums_beta = zeros(num_tensors,num_runs,num_losses);
angles_sums_gamma = zeros(num_tensors,num_runs,num_losses);

for i = 1:num_tensors
    for j = 1:num_runs
        for k = 1:num_losses
            angles_sums_rand(i,j,k) = 1 - sum(rad2deg(angles{1,i,j,k}));
            angles_sums_randn(i,j,k) = sum(rad2deg(angles{2,i,j,k}));
            angles_sums_rayleigh(i,j,k) = sum(rad2deg(angles{3,i,j,k}));
            angles_sums_beta(i,j,k) = sum(rad2deg(angles{4,i,j,k}));
            angles_sums_gamma(i,j,k) = sum(rad2deg(angles{5,i,j,k}));
        end
    end
end

best_sums_rand = zeros(num_tensors,num_losses);
best_sums_randn = zeros(num_tensors, num_losses);
best_sums_rayleigh = zeros(num_tensors, num_losses);
best_sums_beta = zeros(num_tensors, num_losses);
best_sums_gamma = zeros(num_tensors, num_losses);

for i = 1:num_tensors
    for j = 1:num_losses
        best_sums_rand(i,j) = min(angles_sums_rand(i,:,j));
        best_sums_randn(i,j) = min(angles_sums_randn(i,:,j));
        best_sums_rayleigh(i,j) = min(angles_sums_rayleigh(i,:,j));
        best_sums_beta(i,j) = min(angles_sums_beta(i,:,j));
        best_sums_gamma(i,j) = min(angles_sums_gamma(i,:,j));
    end
end