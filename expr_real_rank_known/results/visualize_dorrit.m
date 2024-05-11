%% load data
load("dorrit_rand-init_100-runs_5-losses06-May-2024 14:52:57.mat");
num_losses = length(losses);
%% plot data
figure();
hold on;
for i = 1:num_losses
    objs_plot = plot(log10(dorrit_objectives(:,i)), 'LineStyle','none','Marker','o');
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
    fits_plot = plot(dorrit_fits(:,i), 'LineStyle','none','Marker','o');
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
    cossims_plot = plot(dorrit_cossims(:,i), 'LineStyle','none','Marker','o');
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
    corcondias_plot = plot(dorrit_corcondias(:,i), 'LineStyle','none','Marker','o');
    set(corcondias_plot, 'markerfacecolor', get(corcondias_plot, 'color'));
end
legend(losses);
ylabel('CORCONDIA');
title('CORCONDIA Score')
hold off;

% corcondias (log-scale transformation)
log_corcondias = dorrit_corcondias;
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

%% Remove Normal and Huber for poor corcondia
figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~= 1
        objs_plot = plot(log10(dorrit_objectives(:,i)), 'LineStyle','none','Marker','o');
        set(objs_plot, 'markerfacecolor', get(objs_plot, 'color'));
    end
end
legend(losses{3:5});
ylabel('Objective');
title('Final Objective Values (log scaled)')
hold off;

% fits
figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~= 1
        fits_plot = plot(dorrit_fits(:,i), 'LineStyle','none','Marker','o');
        set(fits_plot, 'markerfacecolor', get(fits_plot, 'color'));
    end
end
legend(losses{3:5});
ylabel('Fit Score');
title('Fit Scores');
hold off;

% cossims
figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~= 1
        cossims_plot = plot(dorrit_cossims(:,i), 'LineStyle','none','Marker','o');
        set(cossims_plot, 'markerfacecolor', get(cossims_plot, 'color'));
    end
end
legend(losses{3:5});
ylabel('Cosine Similarity');
title('Cosine Similarities');
hold off;

% corcondias (log10??)
figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~= 1
        corcondias_plot = plot(dorrit_corcondias(:,i), 'LineStyle','none','Marker','o');
        set(corcondias_plot, 'markerfacecolor', get(corcondias_plot, 'color'));
    end
end
legend(losses{3:5});
ylabel('CORCONDIA');
title('CORCONDIA Score')
hold off;

% corcondias (log-scale transformation)
log_corcondias = dorrit_corcondias;
log_corcondias(log_corcondias > 0) = log10(1+log_corcondias(log_corcondias > 0));
log_corcondias(log_corcondias < 0) = -log10(1-log_corcondias(log_corcondias < 0));

figure();
hold on;
for i = 1:num_losses
    if i ~= 2 && i ~= 1
        log_corcondias_plot = plot(log_corcondias(:,i), 'LineStyle','none','Marker','o');
        set(log_corcondias_plot, 'markerfacecolor', get(log_corcondias_plot, 'color'));
    end
end
legend(losses{3:5});
ylabel('CORCONDIA');
title('CORCONDIA Score (log scale transform)')
hold off

%% best results table
ID = losses';
OBJ = best_dorrit_objectives;
FIT = best_dorrit_fits;
COSSIM = best_dorrit_cossims;
CORCON = best_dorrit_corcondias;

T1 = table(ID,OBJ,FIT,COSSIM,CORCON);