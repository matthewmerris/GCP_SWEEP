%% load the data
load('5-gens_10-tens_100-init_5-losses_19-Jan-2024 20:20:06.mat');
load('5-gens_10-tens_100-init_5-losses_19-Jan-2024 20:20:06_data.mat');
load('ratpack.mat');
load('exception.mat');




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

%% pickup
excp_ten = exception{1};
init_good = exception{2};
nc = size(init_good{1});
nc = nc(2);
init_good = ktensor(init_good);
init_bad = ktensor(exception{3});

losses_bad = {'rayleigh' 'gamma' 'beta'};

[M1_good,M0_good,out_good] = gcp_opt(excp_ten.Data, nc, 'type', losses_bad{1}, 'init', init_good);
[M1_bad, M0_bad, out_bad] = gcp_opt(excp_ten.Data, nc, 'type', losses_bad{1}, 'init', init_bad);
[M1_normal, M0_normal, out_normal] = gcp_opt(excp_ten.Data, nc, 'type', 'normal', 'init', init_bad);

%%
full_good = full(M1_good);
full_bad = full(M1_bad);
full_normal = full(M1_normal);

% calc fitscore without helpers
fit_good = 1 - norm(excp_ten.Data - full_good)/norm(excp_ten.Data);
fit_bad = 1 - norm(excp_ten.Data - full_bad)/norm(excp_ten.Data);
fit_normal = 1 - norm(excp_ten.Data - full_normal)/norm(excp_ten.Data);