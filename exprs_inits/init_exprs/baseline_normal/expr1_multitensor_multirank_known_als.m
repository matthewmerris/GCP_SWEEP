%% Experiment 1: Multi-tensor, multi-rank (known) with cp_als
sz = [100 100 100];
ranks = [5,10,15,20,25];
num_tensors = length(ranks);
num_runs = 10;
inits = ["randn" "arnoldi" "min\_krylov" "nvecs" "gevd"];
num_inits = length(inits);
tol = 1.0e-6;
max_iters = 2000;
noise = 0.0;
sparsity = 0.0;

%%
data_tns = cell(num_tensors,1);
decomps = cell(num_tensors,num_runs,num_inits,3);
init_times = zeros(num_tensors, num_runs, num_inits);

for jdx = 1:num_tensors
    nc = ranks(jdx);
    tns = create_problem('Size', sz, 'Factor_Generator', 'randn', ...
        'Num_Factors', nc,'Sparse_Generation', sparsity, 'Noise', 0);
    data_tns{jdx,1} = tns;
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
        else
            init_times(jdx, idx,4) = init_times(jdx, idx-1,4);
            init_times(jdx, idx,5) = init_times(jdx, idx-1,5);
        end
        
        % ********************* perform decompositions
        if idx == 1
            [decomps{jdx,idx,1,1},decomps{jdx,idx,1,2},decomps{jdx,idx,1,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_rand);
            [decomps{jdx,idx,2,1},decomps{jdx,idx,2,2},decomps{jdx,idx,2,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_arnoldi);
            [decomps{jdx,idx,3,1},decomps{jdx,idx,3,2},decomps{jdx,idx,3,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_krylov);
            [decomps{jdx,idx,4,1},decomps{jdx,idx,4,2},decomps{jdx,idx,4,3}] ...  
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_nvecs);
            [decomps{jdx,idx,5,1},decomps{jdx,idx,5,2},decomps{jdx,idx,5,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_gevd);
        else
            [decomps{jdx,idx,1,1},decomps{jdx,idx,1,2},decomps{jdx,idx,1,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_rand);
            [decomps{jdx,idx,2,1},decomps{jdx,idx,2,2},decomps{jdx,idx,2,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_arnoldi);
            [decomps{jdx,idx,3,1},decomps{jdx,idx,3,2},decomps{jdx,idx,3,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_krylov);
        end
    end
end