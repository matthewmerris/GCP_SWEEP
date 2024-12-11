sz = [100 100 100];
rank = 10;
gens = ["rand","orthogonal", "stochastic"];
num_gens = length(gens);
tens_per_gen = 100;
data_tensors = cell(num_gens,tens_per_gen);
data_Ms = cell(num_gens,tens_per_gen);


for idx = 1:num_gens
    for jdx = 1:tens_per_gen
        [info, ~] = create_problem('Size',sz,'Num_Factors',rank,'Factor_Generator', gens{idx});
        data_tensors{idx,jdx} =  info.Data;
        data_Ms{idx,jdx} = info.Soln;
    end
end

%% decompositions
losses = ["normal", "huber (0.25)","rayleigh", "gamma","beta (0.3)"];
num_losses = length(losses);
Ms_nonneg = cell(num_gens,tens_per_gen, num_losses);
infos_nonneg = cell(num_gens,tens_per_gen, num_losses);

t_start = tic;
for idx = 1:num_gens
    for jdx = 1:tens_per_gen
        sprintf("Gen: %s, Tensor %d",gens{idx},jdx)
        init = arnoldi_cp_init(data_tensors{idx,jdx},rank);
        for kdx = 1:num_losses
            [Ms_nonneg{idx,jdx,kdx},~,infos_nonneg{idx,jdx,kdx}] = gcp_opt(data_tensors{idx,jdx}, rank, ...
                'type', losses{1,kdx}, 'printitn',0, 'init',init);
        end
    end
end
toc(t_start);
