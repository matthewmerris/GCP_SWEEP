%% load the data
load('5-gens_10-tens_100-init_5-losses_19-Jan-2024 20:20:06.mat');
load('5-gens_10-tens_100-init_5-losses_19-Jan-2024 20:20:06_data.mat');

%% identify indices of problematic tensors
idxs = find(fits > 1);
sz = size(fits);

[I_gen, I_ten, I_init, I_loss] = ind2sub(sz,idxs);

num_indxs = length(sz);
num_bad_fits = length(I_gen);
%culprits = zeros(num_bad_fits, num_indxs);
culprits = [I_gen(:), I_ten(:), I_init, I_loss];


%% sort culprits by gen - ten - init 
culprits_sorted = sortrows(culprits,[1 2, 3, 4]);

% some facts:
% number of generators of culprits: 3 (rand - 1, rayleigh - 3, beta - 5)
% only rayleigh, gamma, and beta losses fail
% 8 out of 9 culprits result in fits > 1 for all 100 initializations for
% *** The exception: gen - beta (4) tensor - 1 initialization - 80



%% identify and isolate problematic tensor/initialization tuple
rand_culprits = cell(1,1);
rand_culprits{1,1} = tensors{9,1};

ray_culprits = cell(3,1);
ray_culprits{1,1} = tensors{4,3};
ray_culprits{2,1} = tensors{9,3};
ray_culprits{3,1} = tensors{10,3};

beta_culprits = cell(5,1);
beta_culprits{1,1} = tensors{1,4};
beta_culprits{2,1} = tensors{2,4};
beta_culprits{3,1} = tensors{4,4};
beta_culprits{4,1} = tensors{9,4};
beta_culprits{5,1} = tensors{10,4};

exception{1} = tensors{1,4};
exception{2} = inits{1,4,80};
exception{3} = inits{1,4,81};