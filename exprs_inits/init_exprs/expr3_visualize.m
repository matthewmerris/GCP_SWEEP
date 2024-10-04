%% sparsity experiments split out by sparsity level
% i.e SET THE SPARSITY ACCORDING TO THE DATASET!!
sparsity = 0.99;
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
% for i = 1:num_tensors
%     figure;
%     subplot(1,3,1);
%     


figure;
subplot(2,3,1);
y_min = min(best_fit_scores(1,:),[],"all") - max(std(best_fit_scores(1,:)));
y_max = max(best_fit_scores(1,:),[],"all") + max(std(best_fit_scores(1,:)))/2;
bar(10,best_fit_scores(1,:)');  % excluding gevd currently
% xticklabels(ranks);
ttl = sprintf("Final Fit Score by Rank");
title(ttl);
ylim([y_min y_max]);   % adjust yaxis limit according to dataset
ylabel("Fit Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;
subplot(2,3,2);
bar(10,best_fit_score_iters(1,:));
% xticklabels(ranks);
ttl = sprintf("Final Fit Score by Rank");
title(ttl);
% ylim([y_min y_max]);   % adjust yaxis limit according to dataset
ylabel("Fit Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;
subplot(2,3,3);
bar(10,best_fit_score_opttimes(1,:));
% xticklabels(ranks);
ttl = sprintf("Final Fit Score by Rank");
title(ttl);
% ylim([y_min y_max]);   % adjust yaxis limit according to dataset
ylabel("Fit Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;
subplot(2,3,4);
y_min = min(best_fit_scores(2,:),[],"all") - max(std(best_fit_scores(2,:)));
y_max = max(best_fit_scores(2,:),[],"all") + max(std(best_fit_scores(2,:)))/2;
bar(20,best_fit_scores(2,:));  % excluding gevd currently
% xticklabels(ranks);
ttl = sprintf("Final Fit Score by Rank");
title(ttl);
ylim([y_min y_max]);   % adjust yaxis limit according to dataset
ylabel("Fit Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;
subplot(2,3,5);
bar(20,best_fit_score_iters(2,:));
% xticklabels(ranks);
ttl = sprintf("Final Fit Score by Rank");
title(ttl);
% ylim([y_min y_max]);   % adjust yaxis limit according to dataset
ylabel("Fit Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;
subplot(2,3,6);
bar(20,best_fit_score_opttimes(2,:));
% xticklabels(ranks);
ttl = sprintf("Final Fit Score by Rank");
title(ttl);
% ylim([y_min y_max]);   % adjust yaxis limit according to dataset
ylabel("Fit Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;

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
    ttl = sprintf("Fit Score by Iteration (Rank %d - Sparsity %.2f)",ranks(idx), sparsity);
    title(ttl);
    ylim([y_min y_max]);   % adjust yaxis limit according to dataset
    ylabel("Fit Score");
    xlabel("Iteration");
    legend("rand", "arnoldi", "min\_krylov", "nvecs","gevd");
    
    fontsize(gca, 15, "pixels");
end

%% collect condition numbers and calculate cond scores
cond_nums_init = cell(num_tensors,num_inits);
cond_nums_final = cell(num_tensors,num_inits);
cond_scores_init = zeros(num_tensors,num_inits);
cond_scores_final = zeros(num_tensors,num_inits);
for jdx = 1:num_tensors
    for idx = 1:num_inits
        mdl_init = best_models{jdx,idx}{2};
        mdl_fin = best_models{jdx,idx}{1};
        cns_init = zeros(modes,1);
        cns_final = zeros(modes,1);
        for kdx = 1:modes
            cns_init(kdx) = cond(mdl_init.U{kdx});
            cns_final(kdx) = cond(mdl_fin.U{kdx});
        end
        cond_nums_init{jdx,idx} = cns_init;
        cond_nums_final{jdx,idx} = cns_final;
        cond_scores_init(jdx,idx) = norm(cns_init);
        cond_scores_final(jdx,idx) = norm(cns_final);
    end
end

%% visualize cond scores
figure;
subplot(1,2,1);
bar(cond_scores_init);
xticklabels(ranks);
ttl = sprintf("Initial Cond Score by Rank (Sparsity %.2f)", sparsity);
title(ttl);
% ylim([0.98 1.0]);   % adjust yaxis limit according to dataset
ylabel("Condition Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;
subplot(1,2,2);
bar(cond_scores_final);
xticklabels(ranks);
ttl = sprintf("Final Cond Score by Rank (Sparsity %.2f)", sparsity);
title(ttl);
% ylim([0.98 1.0]);   % adjust yaxis limit according to dataset
ylabel("Condition Score");
xlabel("Tensor Rank");
legend("rand", "arnoldi", "min_krylov", "nvecs", "gevd");
fontsize(gca, 15, "pixels");
grid on;


%% visualize final model condition numbers by mode
conds_by_mode = zeros(num_tensors, modes, num_inits);
for kdx = 1:num_tensors
    for jdx = 1:modes
        for idx = 1:num_inits
            conds_by_mode(kdx,jdx,idx) = cond_nums_final{kdx,idx}(jdx);
        end
    end
end


figure;
for jdx = 1:modes
    subplot(1,modes,jdx);
    bar(squeeze(conds_by_mode(:,jdx,:)));
    xticklabels(ranks);
    ttl = sprintf("Condition Number - Mode %d, Sparsity %.2f", jdx, sparsity);
    title(ttl);
    % ylim([0.98 1.0]);   % adjust yaxis limit according to dataset
    ylabel("Condition Number");
    xlabel("Tensor Rank");
    legend("rand", "arnoldi", "min\_krylov", "nvecs", "gevd");
    fontsize(gca, 15, "pixels");
    grid on;
end

