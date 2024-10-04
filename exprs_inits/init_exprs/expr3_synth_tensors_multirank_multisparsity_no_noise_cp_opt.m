%% Run a series of random experiments on a SINGLE tensor: 
% Intitialization schemes: rand init, nvecs init, gevd, arnoldi init, & min
% krylov recursion.
rng(1339);
sz = [100 100 100];
ranks = [10 20];
num_runs = 10;              % number of runs of 'random' class of inits
num_inits = 5;              % rand, arno, min_krylov, nvecs, gevd
modes = length(sz);
num_tensors = length(ranks);
tol = 1.0e-8;
max_iters = 10000;
sparsity = [.85 .9 .95 .99];


%% Generate tensors, initialize, factorize, collect raw data
for sdx = 1:length(sparsity)
    decomps = cell(num_tensors,num_runs,num_inits,3);
    init_times = zeros(num_tensors, num_runs, num_inits);
    sols = cell(num_tensors,1);
    for jdx = 1:num_tensors
        nc = ranks(jdx);
        tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
            'Num_Factors', nc,'Sparse_Generation', sparsity(sdx), 'Noise', 0);
        sols{jdx,1} = tns.Soln;
        for idx = 1:num_runs
            sprintf("Tensor %d - run %d", jdx, idx)
            
            % ********************* form initializations and init_times
            t_rand = tic;
            init_rand = create_guess('Data',tns.Data, 'Num_Factors', nc, 'Factor_Generator', 'rand');
            init_times(jdx, idx, 1) = toc(t_rand);
            
            t_arno = tic;
            init_arnoldi = arnoldi_cp_init(tns.Data, nc);
            init_times(jdx, idx, 2) = toc(t_arno);
        
            t_kryl = tic;
            [init_krylov, ~, ~] = min_krylov_recursion(tns.Data, nc);
            init_times(jdx, idx, 3) = toc(t_kryl);
            if idx == 1
                t_nvecs = tic;
                init_nvecs = create_guess('Data',tns.Data, 'Num_Factors', nc, 'Factor_Generator', 'nvecs');
                init_times(jdx, idx, 4) = toc(t_nvecs);
                
                tns_matlab = full(tns.Data);
                t_gevd = tic;
                [init_gevd,ot_gevd] = cpd_gevd(tns_matlab.data, nc);
                init_times(jdx, idx, 5) = toc(t_gevd);
                init_gevd = init_gevd';                     % trying to resolve gevd malfunction, likely source is negatives in the factors
                % attempting to resolve by adjusting the factors to be
                % non-negative
                for i = 1:modes
                    init_gevd{i} = init_gevd{i} - min(init_gevd{i},[],"all") + eps;
                end
            else
                init_times(jdx, idx,4) = init_times(jdx, idx-1,4);
                init_times(jdx, idx,5) = init_times(jdx, idx-1,5);
            end
            
            % ********************* perform decompositions
            if idx == 1
                [decomps{jdx,idx,1,1},decomps{jdx,idx,1,2},decomps{jdx,idx,1,3}] ... 
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_rand);
                [decomps{jdx,idx,2,1},decomps{jdx,idx,2,2},decomps{jdx,idx,2,3}] ... 
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_arnoldi);
                [decomps{jdx,idx,3,1},decomps{jdx,idx,3,2},decomps{jdx,idx,3,3}] ... 
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_krylov);
                [decomps{jdx,idx,4,1},decomps{jdx,idx,4,2},decomps{jdx,idx,4,3}] ...  
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_nvecs);
                [decomps{jdx,idx,5,1},decomps{jdx,idx,5,2},decomps{jdx,idx,5,3}] ... 
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_gevd);
            else
                [decomps{jdx,idx,1,1},decomps{jdx,idx,1,2},decomps{jdx,idx,1,3}] ... 
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_rand);
                [decomps{jdx,idx,2,1},decomps{jdx,idx,2,2},decomps{jdx,idx,2,3}] ... 
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_arnoldi);
                [decomps{jdx,idx,3,1},decomps{jdx,idx,3,2},decomps{jdx,idx,3,3}] ... 
                    = cp_opt(tns.Data, nc, 'ftol', tol, 'gtol', tol, 'maxiters', max_iters, ...
                    'printitn', 0, 'lower', 0, 'init', init_krylov);
            end
        end
    end
    
    % save results
    results_filename = sprintf('results/expr3_%dtensor_%dinits_%.2fsparsity_%druns_cp_opt_', num_tensors, num_inits, ...
        sparsity(sdx), num_runs)+ string(datetime("now"));
    save(results_filename, 'sz', 'ranks','num_runs', 'modes', 'tol', 'max_iters', 'sparsity', 'num_tensors', 'num_inits', ...
        'decomps', 'init_times', 'sols');
end

