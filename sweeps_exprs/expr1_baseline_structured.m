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
            [info, ~] = create_problem(sz,rank,'Factor_Generator', gens{idx});
            data_tensors{idx,jdx} =  info.Data;
        end
    end
end

% [tns, k, deets] = create_problem_binary(sz, rank);