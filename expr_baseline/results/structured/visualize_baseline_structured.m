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