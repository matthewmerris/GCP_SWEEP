%% set-up data tensors
amino_path = '~/datasets/real-world-rank-known/amino/claus.mat';
dorrit_path = '~/datasets/real-world-rank-known/dorrit/dorrit.mat';
enron_path = '~/datasets/real-world-rank-unknown/enron/enron_emails.mat';
eem_path = '~/datasets/real-world-rank-known/eem/EEM18.mat';
uber_path = '~/datasets/real-world-rank-unknown/tensor_data_uber/uber.mat';
sugar_path = '~/datasets/real-world-rank-known/sugar/sugar.mat';

% amino_path = '/Users/matthewmerris/datasets/real-world-rank-known/amino/claus.mat';
% dorrit_path = '/Users/matthewmerris/datasets/real-world-rank-known/dorrit/dorrit.mat';
% enron_path = '/Users/matthewmerris/datasets/real-world-rank-unknown/enron/enron_emails.mat';
% eem_path = '/Users/matthewmerris/datasets/real-world-rank-known/eem/EEM18.mat';
% uber_path = '/Users/matthewmerris/datasets/real-world-rank-unknown/tensor_data_uber/uber.mat';
% sugar_path = '/Users/matthewmerris/datasets/real-world-rank-known/sugar/sugar.mat';

dataset_names = ["amino" "dorrit" "enron" "eem" "uber" "sugar"];
ranks = [4 4 10 3 21 4];
dataset_paths = {amino_path, dorrit_path, enron_path, eem_path, uber_path, sugar_path};
num_tensors = length(dataset_paths);

num_runs = 10;
tol = 1.0e-8;
max_iters = 5000;
inits = ['rand' 'arnoldi' 'min\_krylov' 'nvecs' 'gevd'];
num_inits = length(inits);

%% load and prep datasets
data_tns = cell(num_tensors,1);
szs = cell(num_tensors,1);
for kdx = 1:num_tensors
    load(dataset_paths{kdx});
    if strcmp(dataset_names(kdx),"amino")
        load(dataset_paths{kdx});
        tns = tensor(X);
        % % adjust to be non-negative
        min_val = min(tns(:));
        adj_by = -1 * min_val + 10*eps;
        tns = tns + adj_by;
    elseif strcmp(dataset_names(kdx),"dorrit")
        load(dataset_paths{kdx});
        tns = tensor(EEM.data);
        min_val = min(tns(:));
        adj_by = -1 * min_val + 10*eps;
        tns(isnan(tns(:)))=0;
        tns = tns + adj_by;
    elseif strcmp(dataset_names(kdx),"enron")
        load(dataset_paths{kdx});
        tns = Enron; 
    elseif strcmp(dataset_names(kdx),"eem")
        load(dataset_paths{kdx});
        tns = tensor(X);
    elseif strcmp(dataset_names(kdx),"uber")
        load(dataset_paths{kdx});
        tns = sptensor(uber);
    elseif strcmp(dataset_names(kdx),"sugar")
        load(sugar_path);
        tns = tensor(X);
        min_val = min(tns(:));
        adj_by = -1 * min_val + 10*eps;
        tns(isnan(tns(:)))=0;
        tns = tns + adj_by;
%         tns = reshape(tns,[268, 571,7]);
    else
        disp("Trouble now: dataset(s) requested DNE");
    end
    data_tns{kdx} = tns;
    szs{kdx} = ndims(tns);
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
    
        t_kryl = tic;
        [init_krylov, ~, ~] = min_krylov_recursion(tns, nc);
        init_times(jdx, idx, 3) = toc(t_kryl);
        if idx == 1
            t_nvecs = tic;
            init_nvecs = create_guess('Data',tns, 'Num_Factors', nc, 'Factor_Generator', 'nvecs');
            init_times(jdx, idx, 4) = toc(t_nvecs);
            if ~strcmp(dataset_names(jdx),"uber") 
                tns_matlab = full(tns);
                t_gevd = tic;
                [init_gevd,ot_gevd] = cpd_gevd(tns_matlab.data, nc);
                init_times(jdx, idx, 5) = toc(t_gevd);
                init_gevd = init_gevd';                     % trying to resolve gevd malfunction, likely source is negatives in the factors
                % attempting to resolve by adjusting the factors to be
                % non-negative
                for i = 1:modes
                    init_gevd{i} = init_gevd{i} - min(init_gevd{i},[],"all") + eps;
                end
            end
        else
            init_times(jdx, idx,4) = init_times(jdx, idx-1,4);
            init_times(jdx, idx,5) = init_times(jdx, idx-1,5);
        end
        
        % ********************* perform decompositions
        if idx == 1
            [decomps_opt{jdx,idx,1,1},decomps_opt{jdx,idx,1,2},decomps_opt{jdx,idx,1,3}] ... 
                = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                'printitn', 0, 'lower', 0, 'init', init_rand);
            [decomps_opt{jdx,idx,2,1},decomps_opt{jdx,idx,2,2},decomps_opt{jdx,idx,2,3}] ... 
                = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                'printitn', 0, 'lower', 0, 'init', init_arnoldi);
            [decomps_opt{jdx,idx,3,1},decomps_opt{jdx,idx,3,2},decomps_opt{jdx,idx,3,3}] ... 
                = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                'printitn', 0, 'lower', 0, 'init', init_krylov);
            [decomps_opt{jdx,idx,4,1},decomps_opt{jdx,idx,4,2},decomps_opt{jdx,idx,4,3}] ...  
                = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                'printitn', 0, 'lower', 0, 'init', init_nvecs);
            if ~strcmp(dataset_names(jdx),"uber")
                [decomps_opt{jdx,idx,5,1},decomps_opt{jdx,idx,5,2},decomps_opt{jdx,idx,5,3}] ... 
                    = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_gevd);
            end
        else
            [decomps_opt{jdx,idx,1,1},decomps_opt{jdx,idx,1,2},decomps_opt{jdx,idx,1,3}] ... 
                = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                'printitn', 0, 'lower', 0, 'init', init_rand);
            [decomps_opt{jdx,idx,2,1},decomps_opt{jdx,idx,2,2},decomps_opt{jdx,idx,2,3}] ... 
                = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                'printitn', 0, 'lower', 0, 'init', init_arnoldi);
            [decomps_opt{jdx,idx,3,1},decomps_opt{jdx,idx,3,2},decomps_opt{jdx,idx,3,3}] ... 
                = cp_opt(tns, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                'printitn', 0, 'lower', 0, 'init', init_krylov);
        end
    end
end

% save results
results_filename = sprintf('results/expr5_RW_%dtensor_%dinits_%druns_cp_opt_', num_tensors, num_inits, ...
    num_runs)+ string(datetime("now"));
save(results_filename, 'szs', 'ranks','num_runs', 'tol', 'max_iters', 'num_tensors', 'num_inits', ...
    'decomps_opt', 'init_times', 'inits');