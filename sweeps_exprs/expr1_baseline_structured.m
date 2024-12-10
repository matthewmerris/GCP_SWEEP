%% Generate data tensors of known rank
sz = [100 100 100];
rank = 10;
gens = ["binary", "randn", "rand",...
    "orthogonal", "stochastic"];
num_gens = length(gens);
tens_per_gen = 10;
data_tensors = cell(num_gens,tens_per_gen);


for idx = 1:num_gens
    if strcmp(gens{idx}, "binary")
        for jdx = 1:tens_per_gen
            [data_tensors{idx,jdx}, ~, ~] = create_problem_binary(sz,rank);
        end
    else
        for jdx = 1:tens_per_gen
            [info, ~] = create_problem('Size',sz,'Num_Factors',rank,'Factor_Generator', gens{idx});
            data_tensors{idx,jdx} =  info.Data;
        end
    end
end

%% CASE1: Binary - Decompositions
case1_losses = ["normal", "huber (0.25)","binary", "bernoulli-logit"];
num_losses = length(case1_losses);
case1_Ms = cell(tens_per_gen, num_losses);
case1_infos = cell(tens_per_gen, num_losses);

t_start = tic;
for idx = 1:tens_per_gen
    sprintf("Tensor %d",idx)
    init = create_guess('Data', data_tensors{1,idx},'Num_Factors', rank);
    for jdx = 1:num_losses
        [case1_Ms{idx,jdx}, ~, case1_infos{idx,jdx}] = gcp_opt(data_tensors{1,idx}, rank, 'type', case1_losses{1,jdx},...
            'printitn',0, 'init', init);
    end
end
toc(t_start);

%% CASE1: Binary - Collect metrics: FIT, COSSIM, COR, TIME/ITERS
case1_fits = zeros(tens_per_gen, num_losses);
case1_cossims = zeros(tens_per_gen, num_losses);
case1_cors = zeros(tens_per_gen, num_losses);
case1_times = zeros(tens_per_gen, num_losses);

for idx = 1:tens_per_gen
    for jdx = 1:num_losses
        case1_fits(idx,jdx) = fitScore(data_tensors{1,idx}, case1_Ms{idx,jdx});
        case1_cossims(idx,jdx) = cosSim(data_tensors{1,idx}, case1_Ms{idx,jdx}, 3);
        [case1_cors(idx,jdx),~] = efficient_corcondia(data_tensors{1,idx}, case1_Ms{idx,jdx});
        case1_times(idx,jdx) = case1_infos{idx,jdx}.mainTime;
    end
end


%% CASE2: Normal - Decompositions
case2_losses = ["normal", "huber (0.05)"];
num_losses = length(case2_losses);
case2_Ms = cell(tens_per_gen, num_losses);
case2_infos = cell(tens_per_gen, num_losses);

t_start = tic;
for idx = 1:tens_per_gen
    sprintf("Tensor %d",idx)
    init = create_guess('Data', data_tensors{2,idx},'Num_Factors', rank);
    for jdx = 1:num_losses
        [case2_Ms{idx,jdx}, ~, case2_infos{idx,jdx}] = gcp_opt(data_tensors{2,idx}, rank, 'type', case2_losses{1,jdx},...
            'printitn',0, 'init', init);
    end
end
toc(t_start);

%% CASE2: Normal - Collect metrics: FIT, COSSIM, COR, TIME/ITERS
case2_fits = zeros(tens_per_gen, num_losses);
case2_cossims = zeros(tens_per_gen, num_losses);
case2_cors = zeros(tens_per_gen, num_losses);
case2_times = zeros(tens_per_gen, num_losses);

for idx = 1:tens_per_gen
    for jdx = 1:num_losses
        case2_fits(idx,jdx) = fitScore(data_tensors{2,idx}, normalize(case2_Ms{idx,jdx}));
        case2_cossims(idx,jdx) = cosSim(data_tensors{2,idx}, case2_Ms{idx,jdx}, 3);
        [case2_cors(idx,jdx),~] = efficient_corcondia(data_tensors{2,idx}, case2_Ms{idx,jdx});
        case2_times(idx,jdx) = case2_infos{idx,jdx}.mainTime;
    end
end

%% CASE3: Non-negative (Uniform, Orthogonal, Stochastic) - Decompositions
case3_losses = ["normal", "huber (0.25)","rayleigh", "gamma","beta (0.3)"];
num_losses = length(case3_losses);
case3_Ms = cell(3,tens_per_gen,num_losses);
case3_infos = cell(3,tens_per_gen,num_losses);

t_start = tic;
for idx = 3:5
    for jdx = 1:tens_per_gen
        sprintf("Gen: %s, Ten: %d", gens{idx},jdx)
        init = create_guess('Data', data_tensors{idx,jdx},'Num_Factors',rank);
        tmp_i = idx - 2;
        for kdx = 1:num_losses
            [case3_Ms{tmp_i,jdx,kdx},~,case3_infos{tmp_i,jdx,kdx}] = gcp_opt(data_tensors{idx,jdx}, rank,...
                'type', case3_losses{1,kdx}, 'printitn', 0, 'init', init);
        end
    end
end
toc(t_start);

%% CASE3: Non-negative - Collect metrics: FIT, COSSIM, COR, TIME/ITERS
case3_fits = zeros(3,tens_per_gen, num_losses);
case3_cossims = zeros(3,tens_per_gen, num_losses);
case3_cors = zeros(3,tens_per_gen, num_losses);
case3_times = zeros(3,tens_per_gen, num_losses);

for idx = 3:5
    for jdx = 1:tens_per_gen
        for kdx 1:num_losses
            

