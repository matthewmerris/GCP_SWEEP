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
for jdx = 1:num_tensors
    for kdx = 1:num_inits
        if kdx < 4
            best_f = decomps{jdx, 1, kdx,3}.f;
            best_run = 1;
            for idx = 1:num_runs
                tmp_f = decomps{jdx,idx,kdx,3}.f;
                if  tmp_f < best_f
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
        end
    end
end
%% collect best fit score metrics
best_fit_scores = zeros(num_tensors, num_inits);
best_fit_score_traces = cell(num_tensors, num_inits);
best_fit_score_opttimes = zeros(num_tensors,num_inits);
best_fit_score_iters = zeros(num_tensors,num_inits);
for jdx = 1:num_tensors
    for kdx = 1:num_inits
        best_fit_scores(jdx,kdx) = 1 - sqrt(best_models{jdx,kdx}{3}.f);
%         best_fit_score_traces{jdx,kdx} = best_models{jdx,kdx}{3}.optout.f_trace(best_models{jdx,kdx}{3}.optout.f_trace > 0);
        best_fit_score_traces{jdx,kdx} = 1 - sqrt(best_models{jdx,kdx}{3}.optout.f_trace(best_models{jdx,kdx}{3}.optout.f_trace > 0));
        best_fit_score_opttimes(jdx,kdx) = best_models{jdx,kdx}{3}.opttime;
        best_fit_score_iters(jdx,kdx) = best_models{jdx,kdx}{3}.optout.iters;
    end
end

%% bar graph best fit scores by tensor rank
figure;
bar(best_fit_scores);  % excluding gevd currently
xticklabels(ranks);
ttl = sprintf("Final Fit Score by Rank");
title(ttl);
ylim([0.97 1.0]);   % adjust yaxis limit according to dataset
ylabel("Fit Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;

%% plot fit traces for convergence comparison
for idx = 1:num_tensors
    figure;
    hold on;
    [best_fit, itr_indx] = max(best_fit_scores(idx,:));
    best_iter = best_fit_score_iters(idx,itr_indx);
    for jdx = 1:num_inits
        if length(best_fit_score_traces{idx,jdx}) < best_iter
            plot(best_fit_score_traces{idx,jdx}, 'LineWidth', 2);
        else
            plot(best_fit_score_traces{idx,jdx}(1:best_iter), 'LineWidth', 2);
        end
    end 
    ttl = sprintf("Fit Score by Iteration (Rank %d)",ranks(idx));
    title(ttl);
    ylim([0.8 1.0]);   % adjust yaxis limit according to dataset
    ylabel("Fit Score");
    xlabel("Tensor Rank");
    legend("rand", "arnoldi", "min_krylov", "nvecs","gevd");
    fontsize(gca, 15, "pixels");
end