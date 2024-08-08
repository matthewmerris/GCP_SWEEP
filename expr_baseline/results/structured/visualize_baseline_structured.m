%% make a rescaled version of corcondia scores
best_log_corcondias = best_corcondias;
best_log_corcondias(best_log_corcondias > 0) = log10(1+best_log_corcondias(best_log_corcondias > 0));
best_log_corcondias(best_log_corcondias < 0) = -log10(1-best_log_corcondias(best_log_corcondias < 0));

figure;
plot(squeeze(best_log_corcondias(1,:,:)));
legend(losses);

figure;
plot(squeeze(best_log_corcondias(2,:,:)));

figure;
plot(squeeze(best_log_corcondias(3,:,:)));

figure;
plot(squeeze(best_log_corcondias(4,:,:)));

figure;
plot(squeeze(best_log_corcondias(5,:,:)));

%% full metrics plot: rmse, fit score, cossim, corcondia, score

for i=1:num_gens
    % brute force plot and boxplot to be same size in subplot
    % see https://www.mathworks.com/help/matlab/ref/subplot.html
    
    % best objs
    plt1 = figure;
    plot(log10(squeeze(best_objectives(i,:,:))));
    legend(losses);
    ylabel('Objective');
    ax1 = gca;    
    
    bx_plt2 = figure;
    boxplot(log10(squeeze(best_objectives(i,:,:))),'Labels', losses);
    ax2 = gca;
    
    % best rmse
    plt3 = figure;
    plot(log10(squeeze(best_rmses(i,:,:))));
    legend(losses);
    ylabel('RMSE');
    ax3 = gca;    
    
    bx_plt4 = figure;
    boxplot(log10(squeeze(best_rmses(i,:,:))),'Labels', losses);
    ax4 = gca;

    % best fits
    plt5 = figure;
    plot(squeeze(best_fits(i,:,:)));
    legend(losses);
    ylabel('Fit Score');
    ax5 = gca;

    bx_plt6 = figure;
    boxplot(squeeze(best_fits(i,:,:)),'Labels', losses);
    ax6 = gca;

    % best cossims
    plt7 = figure;
    plot(squeeze(best_cossims(i,:,:)));
    legend(losses);
    ylabel('Corcondia Score');
    ax7 = gca;

    bx_plt8 = figure;
    boxplot(squeeze(best_cossims(i,:,:)),'Labels',losses);
    ax8 = gca;

    % best corcondias (log10)
    plt9 = figure;
    plot(squeeze(best_log_corcondias(i,:,:)));
    legend(losses);
    ylabel('Times');
    ax9 = gca;

    bx_plt10 = figure;
    boxplot(squeeze(best_log_corcondias(i,:,:)), 'Labels', losses);
    ax10 = gca;

    % best scores
    plt11 = figure;
    plot(squeeze(best_scores(i,:,:)));
    legend(losses);
    ylabel('Scores');
    ax11 = gca;

    bx_plt12 = figure;
    boxplot(squeeze(best_scores(i,:,:)), 'Labels', losses);
    ax12 = gca;

    % build the plot & boxplot figure
    fnew = figure;
    
    ax1_copy = copyobj(ax1, fnew);
    subplot(6,2,1,ax1_copy(1));
    legend(losses);
    ylabel('Objective');
    copies = copyobj(ax2, fnew);
    ax2_copy = copies(1);
    subplot(6,2,2,ax2_copy);

    ax3_copy = copyobj(ax3, fnew);
    subplot(6,2,3,ax3_copy(1));
    legend(losses);
    ylabel('RMSE');
    copies = copyobj(ax4, fnew);
    ax4_copy = copies(1);
    subplot(6,2,4,ax4_copy);

    ax5_copy = copyobj(ax5, fnew);
    subplot(6,2,5,ax5_copy(1));
    legend(losses);
    ylabel('Fit Score');
    copies = copyobj(ax6, fnew);
    ax6_copy = copies(1);
    subplot(6,2,6,ax6_copy);

    ax7_copy = copyobj(ax7, fnew);
    subplot(6,2,7,ax7_copy(1));
    legend(losses);
    ylabel('Cos Similarity');
    copies = copyobj(ax8, fnew);
    ax8_copy = copies(1);
    subplot(6,2,8,ax8_copy);

    ax9_copy = copyobj(ax9, fnew);
    subplot(6,2,9,ax9_copy(1));
    legend(losses);
    ylabel('Corcondia Score');
    copies = copyobj(ax10, fnew);
    ax10_copy = copies(1);
    subplot(6,2,10,ax10_copy);

    ax11_copy = copyobj(ax11, fnew);
    subplot(6,2,11,ax11_copy(1));
    legend(losses);
    ylabel('Score');
    copies = copyobj(ax12, fnew);
    ax12_copy = copies(1);
    subplot(6,2,12,ax12_copy);


    gen = strcat('Generator - ',gens{i});
    sgtitle(gen);

    % clean up
    figure(plt1);
    close;
    figure(bx_plt2);
    close;
    figure(plt3);
    close;
    figure(bx_plt4);
    close;
    figure(plt5);
    close;
    figure(bx_plt6);
    close;
    figure(plt7);
    close;
    figure(bx_plt8);
    close;
    figure(plt9);
    close;
    figure(bx_plt10);
    close;
    figure(plt11);
    close;
    figure(bx_plt12);
    close;
end

%% build out pre-tables for structured results
% mean best values for 100 generated tensors ---> best_*(num_gens,
% num_tensors, num_losses
for i = 1:num_gens
    fprintf("Generator: %s - average of best", gens{i});
    ID = losses';
%     OBJ = mean(squeeze(best_objectives(i,:,:)))';
    FIT = mean(squeeze(best_fits(i,:,:)))';
    COSSIM = mean(squeeze(best_cossims(i,:,:)))';
    CORCON = mean(squeeze(best_corcondias(i,:,:)))';
%     TIMES = mean(squeeze(best_times(i,:,:)))';
    
    T1 = table(ID,FIT,COSSIM,CORCON)
end

%% build out pre-tables for best of best structured results
for i = 1:num_gens
    fprintf("Generator: %s - best of best", gens{i});
    ID = losses';
%     OBJ = min(squeeze(best_objectives(i,:,:)))';
    FIT = max(squeeze(best_fits(i,:,:)))';
    COSSIM = max(squeeze(best_cossims(i,:,:)))';
    CORCON = max(squeeze(best_corcondias(i,:,:)))';
%     TIMES = min(squeeze(best_times(i,:,:)))';
    
    T1 = table(ID,FIT,COSSIM,CORCON)
end

%% dot plots for best results - general sense of performance of loss functions
% for i = 1:num_gens
%     figure();
%     hold on;
%     for j = 1:num_losses
%         objs_plot = plot(log10(best_objectives(i,:,j)), 'LineStyle','none','Marker','o');
%         set(objs_plot, 'markerfacecolor', get(objs_plot, 'color'));
%     end
%     legend(losses);
%     ylabel('Objective');
%     tmp = strcat("Best OBJs (log scale) - Gen: ", gens{i});
%     title(tmp);
%     hold off;
% end

for i = 1:num_gens
    figure();
    hold on;
    for j = 1:num_losses
        fits_plot = plot(best_fits(i,:,j), 'LineStyle','none','Marker','o');
        set(fits_plot, 'markerfacecolor', get(fits_plot, 'color'));
    end
    legend(losses);
    ylabel('Fit Score');
    tmp = strcat('Best FITs - Gen: ' ,gens{i});
    title(tmp);
    hold off;
end

for i = 1:num_gens
    figure();
    hold on;
    for j = 1:num_losses
        cossim_plot = plot(best_cossims(i,:,j), 'LineStyle','none','Marker','o');
        set(cossim_plot, 'markerfacecolor', get(cossim_plot, 'color'));
    end
    legend(losses);
    ylabel('Cosine Similarity');
    tmp = strcat('Best COSs - Gen: ',gens{i});
    title(tmp);
    hold off;
end
% 
% for i = 1:num_gens
%     figure();
%     hold on;
%     for j = 1:num_losses
%         corcondia_plot = plot(best_corcondias(i,:,j), 'LineStyle','none','Marker','o');
%         set(corcondia_plot, 'markerfacecolor', get(corcondia_plot, 'color'));
%     end
%     legend(losses);
%     ylabel('Corcondia Score');
%     tmp = strcat('Best CORs - Gen: ',gens{i});
%     title(tmp);
%     hold off;
% end

log_best_corcondias = best_corcondias;
log_best_corcondias(log_best_corcondias > 0) = log10(1+log_best_corcondias(log_best_corcondias>0));
log_best_corcondias(log_best_corcondias < 0) = -log10(1-log_best_corcondias(log_best_corcondias<0));

for i = 1:num_gens
    figure();
    hold on;
    for j = 1:num_losses
        log_corcondia_plot = plot(log_best_corcondias(i,:,j), 'LineStyle','none','Marker','o');
        set(log_corcondia_plot, 'markerfacecolor', get(log_corcondia_plot, 'color'));
    end
    legend(losses);
    ylabel('Corcondia Score');
    tmp = strcat('Best CORs (log transform) - Gen: ',gens{i});
    title(tmp);
    hold off;
end
