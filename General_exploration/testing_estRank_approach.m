%% Proding estRank,  
% a modal unfolding approach based on singular value thresholding
% for estimating tensor rank and providing an initialization for the 
% factor matrices of a CP decomposition of a data tensor.
%%
clear; clc;
rng('default');

%% RUN THIS SECTION ON R2/BORAH ONLY!!! adds dependencies to path
addpath(genpath("/bsuhome/mmerris/wares/matlab_tools"));
addpath(genpath("/bsuhome/mmerris/GCP_SWEEP"));

sz = [100,100,100];
ttypes = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'}; % tensor generator types |
num_types = length(ttypes);
runs = 5;

% Initialize results containers
rand_ranks = zeros(runs,1);
randn_ranks = zeros(runs,1);
rayleigh_ranks = zeros(runs,1);
beta_ranks = zeros(runs,1);
gamma_ranks = zeros(runs,1);

% Get to crunching
parpool(48);
for type = 1:num_types
    parfor run = 1:runs
        X = NN_tensor_generator_whole('Size', sz, 'Gen_type', ttypes{type});
        switch ttypes{type}
            case 'rand'
                rand_ranks(run) = rankest(double(X.Data));
            case 'randn'
                randn_ranks(run) = rankest(double(X.Data));
            case 'rayleigh'
                rayleigh_ranks(run) = rankest(double(X.Data));
            case 'beta'
                beta_ranks(run) = rankest(double(X.Data));
            case 'gamma'
                gamma_ranks(run) = rankest(double(X.Data));
        end
    end
end

%% collect results and print
avg_rand_rank = mean(rand_ranks);
avg_randn_rank = mean(randn_ranks);
avg_rayleigh_rank = mean(rayleigh_ranks);
avg_beta_rank = mean(beta_ranks);
avg_gamma_rank = mean(gamma_ranks);

fprintf("avg rand rank: %f\n",avg_rand_rank);
fprintf("avg randn rank: %f\n",avg_randn_rank);
fprintf("avg rayleigh rank: %f\n",avg_rayleigh_rank);
fprintf("avg beta rank: %f\n",avg_beta_rank);
fprintf("avg gamma rank: %f\n",avg_gamma_rank);

%%
exit;
