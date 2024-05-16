%% Redesign of best metrics from plot to scatter
% objectives (log10??)
figure();
hold on;
for i = 1:num_losses
    objs_plot = plot(log10(objectives(:,i)), 'LineStyle','none','Marker','o');
    set(objs_plot, 'markerfacecolor', get(objs_plot, 'color'));
end
legend(losses);
ylabel('Objective');
title('Final Objective Values (log scaled)')
hold off;

% fits
figure();
hold on;
for i = 1:num_losses
    fits_plot = plot(fits(:,i), 'LineStyle','none','Marker','o');
    set(fits_plot, 'markerfacecolor', get(fits_plot, 'color'));
end
legend(losses);
ylabel('Fit Score');
title('Fit Scores');
hold off;

% cossims
figure();
hold on;
for i = 1:num_losses
    cossims_plot = plot(cossims(:,i), 'LineStyle','none','Marker','o');
    set(cossims_plot, 'markerfacecolor', get(cossims_plot, 'color'));
end
legend(losses);
ylabel('Cosine Similarity');
title('Cosine Similarities');
hold off;

% corcondias (log10??)
figure();
hold on;
for i = 1:num_losses
    corcondias_plot = plot(corcondias(:,i), 'LineStyle','none','Marker','o');
    set(corcondias_plot, 'markerfacecolor', get(corcondias_plot, 'color'));
end
legend(losses);
ylabel('CORCONDIA');
title('CORCONDIA Score')
hold off;

% corcondias (log-scale transformation)
log_corcondias = corcondias;
log_corcondias(log_corcondias > 0) = log10(1+log_corcondias(log_corcondias > 0));
log_corcondias(log_corcondias < 0) = -log10(1-log_corcondias(log_corcondias < 0));

figure();
hold on;
for i = 1:num_losses
    log_corcondias_plot = plot(log_corcondias(:,i), 'LineStyle','none','Marker','o');
    set(log_corcondias_plot, 'markerfacecolor', get(log_corcondias_plot, 'color'));
end
legend(losses);
ylabel('CORCONDIA');
title('CORCONDIA Score (log scale transform)')
hold off


%% repeat but for only for losses with non-negative fit scores (losses indices 2 & 5)

figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~=5
        objs_plot = plot(log10(objectives(:,i)), 'LineStyle','none','Marker','o');
        set(objs_plot, 'markerfacecolor', get(objs_plot, 'color'));
    end
end
legend(losses_best);
ylabel('Objective');
title('Final Objective Values (log scaled)')
hold off;
% fits
figure();
hold on;
for i = 1:num_losses
    if i ~=2 && i ~= 5
        fits_plot = plot(fits(:,i), 'LineStyle','none','Marker','o');
        set(fits_plot, 'markerfacecolor', get(fits_plot, 'color'));
    end
end
legend(losses_best);
ylabel('Fit Score');
title('Fit Scores');
hold off;

% cossims
figure();
hold on;
for i = 1:num_losses
    if i ~=2 && i ~= 5
        cossims_plot = plot(cossims(:,i), 'LineStyle','none','Marker','o');
        set(cossims_plot, 'markerfacecolor', get(cossims_plot, 'color'));
    end 
end
legend(losses_best);
ylabel('Cosine Similarity');
title('Cosine Similarities');
hold off;

% corcondias (error in log scaling creeping in)
figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~=5
        corcondias_plot = plot(corcondias(:,i), 'LineStyle','none','Marker','o');
        set(corcondias_plot, 'markerfacecolor', get(corcondias_plot, 'color'));
    end
end
legend(losses_best);
ylabel('CORCONDIA');
title('CORCONDIA Score')
hold off;

% create log-scale version of CORCONDIAS

figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~=5
        corcondias_plot = plot(log_corcondias(:,i), 'LineStyle','none','Marker','o',...
            'MarkerSize',8);
        set(corcondias_plot, 'markerfacecolor', get(corcondias_plot, 'color'));
    end
end
legend(losses_best);
ylabel('CORCONDIA');
title('CORCONDIA Score (log scale transform)')
hold off;

%% table of best results
ID = losses';
OBJ = best_objectives;
FIT = best_fits;
COSSIM = best_cossims;
CORCON = best_corcondias;
% TIMES = best_times;

T1 = table(ID,OBJ,FIT,COSSIM,CORCON)