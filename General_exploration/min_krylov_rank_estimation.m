%% generate a problem and gather relevant details

sz = [100 100 100];
nc = 10;
num_runs = 50;
num_inits = 5;
modes = length(sz);
tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
    'Num_Factors', nc,'Sparse_Generation', .98, 'Noise', 0);

k = max(sz);
[Us,~,~] = min_krylov_recursion(tns,k);

cond_nums = zeros(k, modes);

for jdx = 1:modes
    for idx = 1:k
        conds_nums(idx, jdx) = cond(U{jdx}(:,1:idx));
    end
end
 %% visualize cond_nums for each mode
figure;
for jdx = 1:modes
    subplot(1,modes, jdx);
    plot(conds_nums(:,jdx));
    xlabel('Num_cols');
    ylabel('Cond #');
    title('Mode: ', jdx);
end


