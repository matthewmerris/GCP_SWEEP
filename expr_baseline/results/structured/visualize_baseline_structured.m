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
    
    % best rmse
    plt1 = figure;
    plot(log10(squeeze(best_rmses(i,:,:))));
    legend(losses);
    ylabel('RMSE');
    ax1 = gca;    
    
    bx_plt2 = figure;
    boxplot(log10(squeeze(best_rmses(i,:,:))),'Labels', losses);
    ax2 = gca;

    % best fits
    plt3 = figure;
    plot(squeeze(best_fits(i,:,:)));
    legend(losses);
    ylabel('Fit Score');
    ax3 = gca;

    bx_plt4 = figure;
    boxplot(squeeze(best_fits(i,:,:)),'Labels', losses);
    ax4 = gca;

    % best cossims
    plt5 = figure;
    plot(squeeze(best_cossims(i,:,:)));
    legend(losses);
    ylabel('Corcondia Score');
    ax5 = gca;

    bx_plt6 = figure;
    boxplot(squeeze(best_cossims(i,:,:)),'Labels',losses);
    ax6 = gca;

    % best corcondias (log10)
    plt7 = figure;
    plot(squeeze(best_log_corcondias(i,:,:)));
    legend(losses);
    ylabel('Times');
    ax7 = gca;

    bx_plt8 = figure;
    boxplot(squeeze(best_log_corcondias(i,:,:)), 'Labels', losses);
    ax8 = gca;

    % best scores
    plt9 = figure;
    plot(squeeze(best_scores(i,:,:)));
    legend(losses);
    ylabel('Scores');
    ax9 = gca;

    bx_plt10 = figure;
    boxplot(squeeze(best_scores(i,:,:)), 'Labels', losses);
    ax10 = gca;

    % build the plot & boxplot figure
    fnew = figure;
    
    ax1_copy = copyobj(ax1, fnew);
    subplot(5,2,1,ax1_copy(1));
    legend(losses);
    ylabel('RMSE');
    copies = copyobj(ax2, fnew);
    ax2_copy = copies(1);
    subplot(5,2,2,ax2_copy);

    ax3_copy = copyobj(ax3, fnew);
    subplot(5,2,3,ax3_copy(1));
    legend(losses);
    ylabel('Fit Score');
    copies = copyobj(ax4, fnew);
    ax4_copy = copies(1);
    subplot(5,2,4,ax4_copy);

    ax5_copy = copyobj(ax5, fnew);
    subplot(5,2,5,ax5_copy(1));
    legend(losses);
    ylabel('Cos Similarity');
    copies = copyobj(ax6, fnew);
    ax6_copy = copies(1);
    subplot(5,2,6,ax6_copy);

    ax7_copy = copyobj(ax7, fnew);
    subplot(5,2,7,ax7_copy(1));
    legend(losses);
    ylabel('Corcondia Score');
    copies = copyobj(ax8, fnew);
    ax8_copy = copies(1);
    subplot(5,2,8,ax8_copy);

    ax9_copy = copyobj(ax9, fnew);
    subplot(5,2,9,ax9_copy(1));
    legend(losses);
    ylabel('Score');
    copies = copyobj(ax10, fnew);
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