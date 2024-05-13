% same, but split into individual figures for each generator type
for i=1:num_gens
    % brute force plot and boxplot to be same size in subplot
    % see https://www.mathworks.com/help/matlab/ref/subplot.html
    
    % best fits
    plt1 = figure;
    plot(squeeze(best_fits(i,:,:)));
    legend(losses);
    ylabel('Fit Score');
    ax1 = gca;    
    
    bx_plt2 = figure;
    boxplot(squeeze(best_fits(i,:,:)),'Labels', losses);
    ax2 = gca;

    % best cossims
    plt3 = figure;
    plot(squeeze(best_cossims(i,:,:)));
    legend(losses);
    ylabel('Cos Similarity');
    ax3 = gca;

    bx_plt4 = figure;
    boxplot(squeeze(best_cossims(i,:,:)),'Labels', losses);
    ax4 = gca;

    % best corcondias
    plt5 = figure;
    plot(log10(squeeze(best_corcondias(i,:,:))));
    legend(losses);
    ylabel('Corcondia Score');
    ax5 = gca;

    bx_plt6 = figure;
    boxplot(squeeze(best_corcondias(i,:,:)),'Labels',losses);
    ax6 = gca;

    % best times
    plt7 = figure;
    plot(squeeze(best_times(i,:,:)));
    legend(losses);
    ylabel('Times');
    ax7 = gca;

    bx_plt8 = figure;
    boxplot(squeeze(best_times(i,:,:)), 'Labels', losses);
    ax8 = gca;

    % best rmses
    plt9 = figure;
    plot(squeeze(best_rmses(i,:,:)));
    legend(losses);
    ylabel('RMSEs');
    ax9 = gca;

    bx_plt10 = figure;
    boxplot(squeeze(best_rmses(i,:,:)),'Labels', losses);
    ax10 = gca;

    % build the plot & boxplot figure
    fnew = figure;
    
    ax1_copy = copyobj(ax1, fnew);
    subplot(5,2,1,ax1_copy(1));
    legend(losses);
    ylabel('Fit Score');
    copies = copyobj(ax2, fnew);
    ax2_copy = copies(1);
    subplot(5,2,2,ax2_copy);

    ax3_copy = copyobj(ax3, fnew);
    subplot(5,2,3,ax3_copy(1));
    legend(losses);
    ylabel('Cos Similarity');
    copies = copyobj(ax4, fnew);
    ax4_copy = copies(1);
    subplot(5,2,4,ax4_copy);

    ax5_copy = copyobj(ax5, fnew);
    subplot(5,2,5,ax5_copy(1));
    legend(losses);
    ylabel('Corcondia Score');
    copies = copyobj(ax6, fnew);
    ax6_copy = copies(1);
    subplot(5,2,6,ax6_copy);

    ax7_copy = copyobj(ax7, fnew);
    subplot(5,2,7,ax7_copy(1));
    legend(losses);
    ylabel('Times');
    copies = copyobj(ax8, fnew);
    ax8_copy = copies(1);
    subplot(5,2,8,ax8_copy);

    ax9_copy = copyobj(ax9,fnew);
    subplot(5,2,9,ax9_copy(1));
    legend(losses);
    ylabel('RMSEs');
    copies = copyobj(ax10,fnew);
    ax10_copy = copies(1);
    subplot(5,2,10,ax10_copy);



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
end

%% create 'cleaned' version of resulst (i.e. fits > 1) based on fit
cl_best_fits = best_fits;
cl_best_fits(cl_best_fits > 1) = NaN;

idx = find(best_fits > 1);

cl_best_cossims = best_cossims;
cl_best_cossims(idx) = NaN;

cl_best_times = best_times;
cl_best_times(idx) = NaN;

cl_best_corcondias = best_corcondias;
cl_best_corcondias(idx) = NaN;


%% make clean version of above
for i=1:num_gens
    % brute force plot and boxplot to be same size in subplotclear
    % see https://www.mathworks.com/help/matlab/ref/subplot.html
    
    % best fits
    plt1 = figure;
    plot(squeeze(cl_best_fits(i,:,:)));
    legend(losses);
    ylabel('Fit Score');
    ax1 = gca;    
    
    bx_plt2 = figure;
    boxplot(squeeze(cl_best_fits(i,:,:)),'Labels', losses);
    ax2 = gca;

    % best cossims
    plt3 = figure;
    plot(squeeze(cl_best_cossims(i,:,:)));
    legend(losses);
    ylabel('Cos Similarity');
    ax3 = gca;    
    
    bx_plt4 = figure;
    boxplot(squeeze(cl_best_cossims(i,:,:)),'Labels', losses);
    ax4 = gca;

    % best corcondias
    plt5 = figure;
    plot(squeeze(cl_best_corcondias(i,:,:)));
    legend(losses);
    ylabel('Corcondia Score');
    ax5 = gca;    
    
    bx_plt6 = figure;
    boxplot(squeeze(cl_best_corcondias(i,:,:)),'Labels', losses);
    ax6 = gca;

    % best times
    plt7 = figure;
    plot(squeeze(cl_best_times(i,:,:)));
    legend(losses);
    ylabel('Times(secs)');
    ax7 = gca;    
    
    bx_plt8 = figure;
    boxplot(squeeze(cl_best_times(i,:,:)),'Labels', losses);
    ax8 = gca;

    % build the plot & boxplot figure
    fnew = figure;
    
    ax1_copy = copyobj(ax1, fnew);
    subplot(4,2,1,ax1_copy(1));
    legend(losses);
    ylabel('Fit Score');
    copies = copyobj(ax2, fnew);
    ax2_copy = copies(1);
    subplot(4,2,2,ax2_copy);

    ax3_copy = copyobj(ax3, fnew);
    subplot(4,2,3,ax3_copy(1));
    legend(losses);
    ylabel('Cos Similarity');
    copies = copyobj(ax4, fnew);
    ax4_copy = copies(1);
    subplot(4,2,4,ax4_copy);

    ax5_copy = copyobj(ax5, fnew);
    subplot(4,2,5,ax5_copy(1));
    legend(losses);
    ylabel('Corcondia Score');
    copies = copyobj(ax6, fnew);
    ax6_copy = copies(1);
    subplot(4,2,6,ax6_copy);

    ax7_copy = copyobj(ax7, fnew);
    subplot(4,2,7,ax7_copy(1));
    legend(losses);
    ylabel('Times');
    copies = copyobj(ax8, fnew);
    ax8_copy = copies(1);
    subplot(4,2,8,ax8_copy);


    gen = strcat('Generator - ',gens{i},'(cleaned)');
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
end
%% Table: averages of best results from 100 intializations for each of
% 100 generated tensors best_metric(num_gens, num_tensors, num_losses)
for i = 1:num_gens
    fprintf("Generator: %s - average of best", gens{i});
    ID = losses';
    OBJ = mean(squeeze(best_objectives(i,:,:)))';
    FIT = mean(squeeze(best_fits(i,:,:)))';
    COSSIM = mean(squeeze(best_cossims(i,:,:)))';
    CORCON = mean(squeeze(best_corcondias(i,:,:)))';
%     TIMES = mean(squeeze(best_times(i,:,:)))';
    
    T1 = table(ID,OBJ,FIT,COSSIM,CORCON)
end

%% Table: best of the best metrics (not sure if this is very informative)
for i = 1:num_gens
    fprintf("Generator: %s - best of best", gens{i});
    ID = losses';
    OBJ = min(squeeze(best_objectives(i,:,:)))';
    FIT = max(squeeze(best_fits(i,:,:)))';
    COSSIM = max(squeeze(best_cossims(i,:,:)))';
    CORCON = max(squeeze(best_corcondias(i,:,:)))';
%     TIMES = min(squeeze(best_times(i,:,:)))';
    
    T1 = table(ID,OBJ,FIT,COSSIM,CORCON)
end

%% build figures (plot) for best_metrics

for i = 1:num_gens
    figure();
    hold on;
    for j = 1:num_losses
        objs_plot = plot(log10(best_objectives(i,:,j)), 'LineStyle','none','Marker','o');
        set(objs_plot, 'markerfacecolor', get(objs_plot, 'color'));
    end
    legend(losses);
    ylabel('Objective');
    tmp = strcat("Best OBJs (log scale) - Gen: ", gens{i});
    title(tmp);
    hold off;
end

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

%% build figures (plot) for best_metrics - remove beta loss results from  *****WIP******

for i = 1:num_gens
    figure();
    hold on;
    for j = 1:num_losses
        objs_plot = plot(log10(best_objectives(i,:,j)), 'LineStyle','none','Marker','o');
        set(objs_plot, 'markerfacecolor', get(objs_plot, 'color'));
    end
    legend(losses);
    ylabel('Objective');
    tmp = strcat("Best OBJs (log scale) - Gen: ", gens{i});
    title(tmp);
    hold off;
end

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
%% mean and std of ranks
