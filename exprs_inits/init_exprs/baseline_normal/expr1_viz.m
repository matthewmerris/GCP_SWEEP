%% load results (variable name consistency applied)
%% collect average initialization times
avg_times = zeros(num_tensors, num_inits);
for jdx = 1:num_tensors
    for idx = 1:num_inits
        avg_times(jdx,idx) = mean(init_times(jdx,:,idx));
    end
end

%% plot average times by rank
figure;
bar(avg_times);
xticklabels(ranks);
ttl = sprintf("Initialization times by rank");
title(ttl);
ylabel("Time (seconds)");
xlabel("Tesor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 20, "pixels");
grid on;

%% identify best model out runs for each tensor
best_models = cell(num_tensors, num_inits);
all_fits = zeros(num_tensors, num_runs, num_inits);
for jdx = 1:num_tensors
    for kdx = 1:num_inits
        if kdx < 4
            best_f = max(decomps{jdx, 1, kdx,3}.fits);
            best_run = 1;
            for idx = 1:num_runs
                tmp_f = max(decomps{jdx,idx,kdx,3}.fits);
                all_fits(jdx,idx,kdx) = tmp_f;
                if  tmp_f > best_f
                    best_run = idx;
                end
            end
            tmp_best = cell(3,1);
            for i = 1:3
                tmp_best{i,1} = decomps{jdx, best_run,kdx,i};
            end
            best_models{jdx,kdx} = tmp_best;
        else
            tmp_best = cell(3,1);
            for i = 1:3
                tmp_best{i,1} = decomps{jdx, 1,kdx,i};
            end
            best_models{jdx,kdx} = tmp_best;
            best_f = max(decomps{jdx,1,kdx,3}.fits);
            for idx = 1:num_runs
                all_fits(jdx,idx,kdx) = best_f;
            end
        end
    end
end

%% boxplot for each tensor (fit score for all runs)
for jdx = 1:num_tensors
    figure;
    if jdx == num_tensors
        boxplot(squeeze(all_fits(jdx,:,1:4)));
    else
        boxplot(squeeze(all_fits(jdx,:,:)));
    end
end