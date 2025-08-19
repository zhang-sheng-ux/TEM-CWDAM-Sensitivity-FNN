clear; clc;
load('permutation_grouped_sensitivity.mat');

latex_names = {'b', 'H', 'b_c', 'H_w', '\rho_d', '\rho_f', '\rho_c', '\rho_w'};
geo_names = latex_names(geo_idx);
elec_names = latex_names(elec_idx);

n_times = length(timeslog);
window = 7;
geo_colors = lines(length(geo_idx));
elec_colors = lines(length(elec_idx));
xticks_log = 10.^(-7:-2);
xticklabels_log = {'$10^{-7}$','$10^{-6}$','$10^{-5}$','$10^{-4}$','$10^{-3}$','$10^{-2}$'};

%% ----------- Geometry group (log-x) -----------
figure('Color','w','Position',[100 100 800 600]); hold on;
h_curve = gobjects(1,length(geo_idx));
for i = 1:length(geo_idx)
    k = geo_idx(i);
    mu_raw = mean(perm_importance_raw(k,:,:),3);
    sigma_raw = std(perm_importance_raw(k,:,:),0,3);
    mu = movmean(mu_raw, window, 2);
    sigma = movmean(sigma_raw, window, 2);

    low = mu - sigma;
    high = mu + sigma;
    if i==1
        h_ci = fill([timeslog; flipud(timeslog)], [low fliplr(high)], [0.6 0.6 0.6], ...
            'FaceAlpha', 0.22, 'EdgeColor','none', 'DisplayName', '$\pm$1$\sigma$ band');
    else
        fill([timeslog; flipud(timeslog)], [low fliplr(high)], geo_colors(i,:), ...
            'FaceAlpha', 0.17, 'EdgeColor','none', 'HandleVisibility','off');
    end
    h_curve(i) = plot(timeslog, perm_importance_movmean(k,:), '-', ...
        'Color', geo_colors(i,:), ...
        'LineWidth', 2.4, ...
        'DisplayName', ['$' geo_names{i} '$']);
end

ax = gca;
set(ax, ...
    'xscale','log', ...
    'TickLabelInterpreter', 'latex', ...
    'FontSize', 18, ...
    'LineWidth',1.5, ...
    'XColor','k', ...
    'YColor','k', ...
    'Box','off', ...
    'FontName', 'Times New Roman');
xlabel('Times (s)','FontSize',20,'Interpreter','latex');
ylabel('Time-varying Sensitivity','FontSize',20,'Interpreter','latex');
title('Geometry boundary sensitivity with log-time','FontSize',17,'Interpreter','latex');
ylim([0 0.1]);
xlim([1e-7 1e-2]);
set(ax,'XTick',xticks_log,'XTickLabel',xticklabels_log);

% 美化网格线
grid on;
ax.GridLineStyle = '-';
ax.GridAlpha = 0.25;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridLineStyle = '-';
ax.MinorGridAlpha = 0.10;
ax.MinorGridColor = [0.7 0.7 0.7];
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.TickDir = 'out';
ax.Layer = 'top';

plot([1e-7 1e-2], [0 0], 'k', 'LineWidth', 1.5);
plot([1e-7 1e-2], [0.1 0.1], 'k', 'LineWidth', 1.5);
plot([1e-7 1e-7], [0 0.1], 'k', 'LineWidth', 1.5);
plot([1e-2 1e-2], [0 0.1], 'k', 'LineWidth', 1.5);

param_legends = cellfun(@(x) ['$' x '$'], geo_names, 'UniformOutput',false);
h_leg = legend([h_curve h_ci], [param_legends {'$\pm$1$\sigma$ band'}], ...
    'Location','best','Interpreter','latex','FontSize',18);
set(h_leg, 'Box', 'off', 'Color', 'none');
set(gca, 'FontName', 'Times New Roman');
set(findall(gcf,'Type','text'),'FontName','Times New Roman');
hold off;

%% ----------- Electrical group (log-x) -----------
figure('Color','w','Position',[100 100 800 600]); hold on;
h_curve = gobjects(1,length(elec_idx));
for i = 1:length(elec_idx)
    k = elec_idx(i);
    mu_raw = mean(perm_importance_raw(k,:,:),3);
    sigma_raw = std(perm_importance_raw(k,:,:),0,3);
    mu = movmean(mu_raw, window, 2);
    sigma = movmean(sigma_raw, window, 2);

    low = mu - sigma;
    high = mu + sigma;
    if i==1
        h_ci = fill([timeslog; flipud(timeslog)], [low fliplr(high)], [0.6 0.6 0.6], ...
            'FaceAlpha', 0.22, 'EdgeColor','none', 'DisplayName', '$\pm$1$\sigma$ band');
    else
        fill([timeslog; flipud(timeslog)], [low fliplr(high)], elec_colors(i,:), ...
            'FaceAlpha', 0.17, 'EdgeColor','none', 'HandleVisibility','off');
    end
    h_curve(i) = plot(timeslog, perm_importance_movmean(k,:), '-', ...
        'Color', elec_colors(i,:), ...
        'LineWidth', 2.4, ...
        'DisplayName', ['$' elec_names{i} '$']);
end

ax = gca;
set(ax, ...
    'xscale','log', ...
    'TickLabelInterpreter', 'latex', ...
    'FontSize', 18, ...
    'LineWidth',1.5, ...
    'XColor','k', ...
    'YColor','k', ...
    'Box','off', ...
    'FontName', 'Times New Roman');
xlabel('Times (s)','FontSize',20,'Interpreter','latex');
ylabel('Time-varying Sensitivity','FontSize',20,'Interpreter','latex');
title('Resistivity boundary sensitivity with log-time','FontSize',17,'Interpreter','latex');
ylim([0 1]);
xlim([1e-7 1e-2]);
set(ax,'XTick',xticks_log,'XTickLabel',xticklabels_log);

grid on;
ax.GridLineStyle = '-';
ax.GridAlpha = 0.25;
ax.GridColor = [0.5 0.5 0.5];
ax.MinorGridLineStyle = '-';
ax.MinorGridAlpha = 0.10;
ax.MinorGridColor = [0.7 0.7 0.7];
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.TickDir = 'out';
ax.Layer = 'top';

plot([1e-7 1e-2], [0 0], 'k', 'LineWidth', 1.5);
plot([1e-7 1e-2], [1 1], 'k', 'LineWidth', 1.5);
plot([1e-7 1e-7], [0 1], 'k', 'LineWidth', 1.5);
plot([1e-2 1e-2], [0 1], 'k', 'LineWidth', 1.5);

param_legends = cellfun(@(x) ['$' x '$'], elec_names, 'UniformOutput',false);
h_leg = legend([h_curve h_ci], [param_legends {'$\pm$1$\sigma$ band'}], ...
    'Location','best','Interpreter','latex','FontSize',18);
set(h_leg, 'Box', 'off', 'Color', 'none');
set(gca, 'FontName', 'Times New Roman');
set(findall(gcf,'Type','text'),'FontName','Times New Roman');
hold off;
