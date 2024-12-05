%% Generate data tensors of known rank
sz = [100 100 100];
rank = 10;
gens = ["binary", "rand", "randn", ...
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
losses = ["normal", "huber (0.25)","binary", "bernoulli-logit"];
num_losses = length(losses);
mdl_Ms = cell(tens_per_gen, num_losses);
mdl_infos = cell(tens_per_gen, num_losses);

t_start = tic;
for idx = 1:tens_per_gen
    sprintf("Tensor %d",idx)
    init = create_guess('Data', data_tensors{1,idx},'Num_Factors', rank);
    for jdx = 1:num_losses
        [mdl_Ms{idx,jdx}, ~, mdl_infos{idx,jdx}] = gcp_opt(data_tensors{1,idx}, rank, 'type', losses{1,jdx},...
            'printitn',0, 'init', init);
    end
end
toc(t_start);

%% CASE1: Binary - Collect metrics: FIT, COSSIM, COR, TIME/ITERS
fits_case1 = zeros(tens_per_gen, num_losses);
cossims_case1 = zeros(tens_per_gen, num_losses);
cors_case1 = zeros(tens_per_gen, num_losses);
times_case1 = zeros(tens_per_gen, num_losses);

for idx = 1:tens_per_gen
    for jdx = 1:num_losses
        fits_case1(idx,jdx) = fitScore(data_tensors{1,idx}, mdl_Ms{idx,jdx});
        cossims_case1(idx,jdx) = cosSim(data_tensors{1,idx}, mdl_Ms{idx,jdx}, 3);
        [cors_case1(idx,jdx),~] = efficient_corcondia(data_tensors{1,idx}, mdl_Ms{idx,jdx});
        times_case1(idx,jdx) = mdl_infos{idx,jdx}.mainTime;
    end
end
