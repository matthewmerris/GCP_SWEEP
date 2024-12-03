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

%% CASE1: Binary
losses = ["normal", "huber (0.25)","binary", "bernoulli-logit"];
num_losses = length(losses);
mdl_Ms = cell(tens_per_gen, num_losses);
mdl_infos = cell(tens_per_gen, num_losses);

for idx = 1:tens_per_gen
    for jdx = 1:num_losses
        [mdl_Ms{idx,jdx}, ~, mdl_infos{idx,jdx}] = gcp_opt(data_tensors{1,idx}, )