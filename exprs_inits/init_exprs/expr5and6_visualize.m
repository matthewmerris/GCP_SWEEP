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
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 20, "pixels");
grid on;

%% identify best model out runs for each tensor
best_models = cell(num_tensors, num_inits);
for jdx = 1:num_tensors
    for kdx = 1:num_inits
        if kdx < 4
            best_f = decomps_opt{jdx, 1, kdx,3}.f;
            best_run = 1;
            for idx = 1:num_runs
                tmp_f = decomps_opt{jdx,idx,kdx,3}.f;
                if  tmp_f < best_f
                    best_run = idx;
                end
            end
            tmp_best = cell(3,1);
            for i = 1:3
                tmp_best{i,1} = decomps_opt{jdx, best_run,kdx,i};
            end
            best_models{jdx,kdx} = tmp_best;
        else
            tmp_best = cell(3,1);
            for i = 1:3
                tmp_best{i,1} = decomps_opt{jdx, 1,kdx,i};
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
%%
for idx = 1:num_tensors
    figure;
    subplot(1,3,1);
    y_min = min(best_fit_scores(idx,:),[],"all") - max(std(best_fit_scores(idx,:)));
    y_max = max(best_fit_scores(idx,:),[],"all") + max(std(best_fit_scores(idx,:)))/2;
    bar(10,best_fit_scores(idx,:)');  % excluding gevd currently
    ttl = sprintf("Final Fit Score");
    title(ttl);
    ylim([y_min y_max]);   % adjust yaxis limit according to dataset
    ylabel("Fit Score");
    xlabel("Tensor Rank");
    legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
    fontsize(gca, 15, "pixels");
    grid on;
    % barplot (subplot) total iterations
    subplot(1,3,2);
    bar(10,best_fit_score_iters(idx,:));
    % xticklabels(ranks);
    ttl = sprintf("Total Iteration");
    title(ttl);
    % ylim([y_min y_max]);   % adjust yaxis limit according to dataset
    ylabel("Iterations");
    xlabel("Tensor Rank");
    legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
    fontsize(gca, 15, "pixels");
    grid on;
    % barplot (subplot) total time
    subplot(1,3,3);
    bar(10,best_fit_score_opttimes(idx,:)./60);
    % xticklabels(ranks);
    ttl = sprintf("Total Optimization Time");
    title(ttl);
    % ylim([y_min y_max]);   % adjust yaxis limit according to dataset
    ylabel("Time (min)");
    xlabel("Tensor Rank");
    legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
    fontsize(gca, 15, "pixels");
    grid on;
end



%% plot fit traces for convergence comparison
for idx = 1:num_tensors
    y_max = max(best_fit_scores(idx,:)) + std(best_fit_scores(idx,:));
    y_min = min(best_fit_scores(idx,:)) - y_max/10;
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
    ttl = sprintf("Fit Score by Iteration (%s - Rank %d)",dataset_names{idx},ranks(idx));
    title(ttl);
    ylim([y_min y_max]);   % adjust yaxis limit according to dataset
    ylabel("Fit Score");
    xlabel("Iteration");
    legend("rand", "arnoldi", "min\_krylov", "nvecs","gevd");
    
    fontsize(gca, 15, "pixels");
end