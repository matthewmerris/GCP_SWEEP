% lbnl_path = '~/datasets/FROSTT/lbnl_network/lbnl-network.tns';  % too big
% vast5d_path = '~/datasets/FROSTT/vast_2015_mini/vast-2015-mc1-5d.tns'; % too big
vast3d_path = '~/datasets/FROSTT/vast_2015_mini/vast-2015-mc1-3d.tns';
nell2_path = '~/datasets/FROSTT/nell2/nell-2.tns';
uber_path = '~/datasets/real-world-rank-unknown/tensor_data_uber/uber.mat';
chi_path = '~/datasets/real-world-rank-unknown/tensor_data_chicago_crime/chicago_crime.mat';
chi_2019_path = '~/datasets/real-world-rank-unknown/tensor_data_chicago_crime/chicago_crime_2019.mat';
nips_path = '~/datasets/FROSTT/

dataset_names = [ "vast3d","nell2","uber", "chicago", "chicago_2019", "nips"];
ranks = [10,10,10,10,10];
dataset_paths = {vast3d_path, nell2_path, uber_path, chi_path, chi_2019_path, nips_path};
num_tensors = length(dataset_paths);

num_runs = 10;
tol = 1.0e-6;
max_iters = 5000;
% inits = ["rand" "arnoldi" "min\_krylov" "nvecs"];
inits = ["rand" "arnoldi"];
num_inits = length(inits);

%% load and prep datasets
data_tns = cell(num_tensors,1);
szs = cell(num_tensors,1);
for kdx = 1:num_tensors
    load(dataset_paths{kdx});
    if strcmp(dataset_names(kdx),"enron")
        load(dataset_paths{kdx});
        tns = sptensor(Enron);
    elseif strcmp(dataset_names(kdx),"uber")
        load(dataset_paths{kdx});
        tns = sptensor(uber);
    elseif strcmp(dataset_names(kdx),"chicago") || strcmp(dataset_names(kdx),"chicago_2019")
        load(dataset_paths{kdx});
        tns = sptensor(X);
    elseif strcmp(dataset_names{kdx}, "lbnl")
        tns = load_frostt(dataset_paths{kdx});
        tns = tns(:,:,:,:,1:86400);
    elseif strcmp(dataset_names{kdx}, "nips")
        tns = load_frostt(dataset_paths{kdx});
        tns = squeeze(tns(:,:,:,:,1));
    elseif strcmp(dataset_names(kdx),"vast5d") || strcmp(dataset_names(kdx),"vast3d") ...
            || strcmp(dataset_names(kdx),"nell2")
        tns = load_frostt(dataset_paths{kdx});
    else
        disp("Trouble now: dataset(s) requested DNE");
    end
    data_tns{kdx} = tns;
    szs{kdx} = size(tns);
end

%% set-up initialization experiments
init_times = zeros(num_tensors, num_runs, num_inits);
decomps_opt = cell(num_tensors, num_runs, num_inits,3);
% decomps_als = cell(num_tensors, num_runs, num_inits,3);
for jdx = 1:num_tensors
    nc = ranks(jdx);
    tns = data_tns{jdx};
    modes = ndims(tns);
    for idx = 1:num_runs
        % ********************* form initializations and init_times
        t_rand = tic;
        init_rand = create_guess('Data',tns, 'Num_Factors', nc, 'Factor_Generator', 'rand');
        init_times(jdx, idx, 1) = toc(t_rand);
        
        t_arno = tic;
        init_arnoldi = arnoldi_cp_init(tns, nc);
        init_times(jdx, idx, 2) = toc(t_arno);
    
%         t_kryl = tic;
%         [init_krylov, ~, ~] = min_krylov_recursion(tns, nc);
%         init_times(jdx, idx, 3) = toc(t_kryl);
%         if idx == 1
%             t_nvecs = tic;
%             init_nvecs = create_guess('Data',tns, 'Num_Factors', nc, 'Factor_Generator', 'nvecs');
%             init_times(jdx, idx, 4) = toc(t_nvecs);
%         else
%             init_times(jdx, idx,4) = init_times(jdx, idx-1,4);
%         end
        
        % ********************* perform decompositions
%         if idx == 1
%             [decomps_opt{jdx,idx,1,1},decomps_opt{jdx,idx,1,2},decomps_opt{jdx,idx,1,3}] ... 
%                 = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
%                 'printitn', 0, 'lower', 0, 'init', init_rand);
%             [decomps_opt{jdx,idx,2,1},decomps_opt{jdx,idx,2,2},decomps_opt{jdx,idx,2,3}] ... 
%                 = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
%                 'printitn', 0, 'lower', 0, 'init', init_arnoldi);
% %             [decomps_opt{jdx,idx,3,1},decomps_opt{jdx,idx,3,2},decomps_opt{jdx,idx,3,3}] ... 
% %                 = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
% %                 'printitn', 0, 'lower', 0, 'init', init_krylov);
% %             [decomps_opt{jdx,idx,4,1},decomps_opt{jdx,idx,4,2},decomps_opt{jdx,idx,4,3}] ...  
% %                 = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
% %                 'printitn', 0, 'lower', 0, 'init', init_nvecs);
%         else
%             [decomps_opt{jdx,idx,1,1},decomps_opt{jdx,idx,1,2},decomps_opt{jdx,idx,1,3}] ... 
%                 = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
%                 'printitn', 0, 'lower', 0, 'init', init_rand);
%             [decomps_opt{jdx,idx,2,1},decomps_opt{jdx,idx,2,2},decomps_opt{jdx,idx,2,3}] ... 
%                 = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
%                 'printitn', 0, 'lower', 0, 'init', init_arnoldi);
% %             [decomps_opt{jdx,idx,3,1},decomps_opt{jdx,idx,3,2},decomps_opt{jdx,idx,3,3}] ... 
% %                 = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
% %                 'printitn', 0, 'lower', 0, 'init', init_krylov);
%         end
    end
end

%% save results
results_filename = sprintf('results/expr7_RW_big_and_sparse_%dtensor_%dinits_%druns_cp_opt_', num_tensors, num_inits, ...
    num_runs)+ string(datetime("now"));
save(results_filename, 'szs', 'ranks','num_runs', 'tol', 'max_iters', 'num_tensors', 'num_inits', ...
    'decomps_opt', 'init_times', 'inits', "dataset_names");