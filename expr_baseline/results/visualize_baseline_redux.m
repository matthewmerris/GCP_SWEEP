%% same, but split into individual figures for each generator type
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
    plot(squeeze(best_corcondias(i,:,:)));
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
%% make standard plots and boxplots of raw results (grouped by metric)