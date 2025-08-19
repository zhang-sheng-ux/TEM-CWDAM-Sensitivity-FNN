%% 分组时序Permutation敏感性分析（几何边界/电阻率边界，重复+平滑）
clear; clc;
load('normalized_data.mat');   %加载数据结构体

param_names = {'坡比','坝高','心墙坡比','水位','坝体电阻率','坝基电阻率','心墙电阻率','水体电阻率'};
Np = length(param_names);

geo_idx = 1:4;
elec_idx = 5:8;
geo_names = param_names(geo_idx);
elec_names = param_names(elec_idx);

n_samples = length(normalized_data);
n_times = length(normalized_data(1).Bz_log);

% 确保 timeslog 正确获取
if isfield(normalized_data, 'timeslog')
    timeslog = normalized_data(1).timeslog;
elseif isfield(normalized_data, 'time')
    timeslog = normalized_data(1).time;
else
    timeslog = 1:n_times; % 无则用索引
end

X = zeros(n_samples, Np);
Y = zeros(n_samples, n_times);
for i = 1:n_samples
    X(i,:) = normalized_data(i).X_norm(:)'; % 强制为行向量
    Y(i,:) = normalized_data(i).Bz_log(:)'; % 强制为行向量
end

% ------- 重复Permutation --------
repeats = 5;
perm_importance_raw = zeros(Np, n_times, repeats);
for rep = 1:repeats
    for t = 1:n_times
        y_true = Y(:, t);
        model = TreeBagger(50, X, y_true, 'Method', 'regression', 'OOBPrediction', 'off');
        y_pred_ref = predict(model, X);
        ref_corr = corr(y_pred_ref, y_true);

        for k = 1:Np
            X_perm = X;
            X_perm(:,k) = X(randperm(n_samples), k);
            y_pred_perm = predict(model, X_perm);
            perm_corr = corr(y_pred_perm, y_true);
            perm_importance_raw(k, t, rep) = ref_corr - perm_corr;
        end
    end
end

% 取均值（重复平均）
perm_importance = mean(perm_importance_raw, 3);

% ------- 平滑方式1：滑动平均 -------
window = 7;
perm_importance_movmean = movmean(perm_importance, window, 2);

% ------- 平滑方式2：Savitzky-Golay滤波 -------
polyorder = 2;
perm_importance_sgolay = sgolayfilt(perm_importance, polyorder, window, [], 2);

%% 曲线展示分组敏感性（原始/滑动均值/Savitzky-Golay可对比）
figure('Color','w','Position',[100 100 1150 460]);
subplot(1,3,1); hold on;
for i = 1:length(geo_idx)
    plot(1:n_times, perm_importance(geo_idx(i),:), '-o', 'LineWidth',2, 'DisplayName',geo_names{i});
end
xlabel('时序点','FontSize',12); ylabel('敏感性','FontSize',12);
title('几何-原始'); legend('show','Location','best'); grid on;
ylim([0, max(perm_importance(:))*0.1]);

subplot(1,3,2); hold on;
for i = 1:length(geo_idx)
    plot(1:n_times, perm_importance_movmean(geo_idx(i),:), '-o', 'LineWidth',2, 'DisplayName',geo_names{i});
end
xlabel('时序点','FontSize',12); ylabel('敏感性','FontSize',12);
title('几何-滑动平均'); legend('show','Location','best'); grid on;
ylim([0, max(perm_importance(:))*0.1]);

subplot(1,3,3); hold on;
for i = 1:length(geo_idx)
    plot(1:n_times, perm_importance_sgolay(geo_idx(i),:), '-o', 'LineWidth',2, 'DisplayName',geo_names{i});
end
xlabel('时序点','FontSize',12); ylabel('敏感性','FontSize',12);
title('几何-Savitzky-Golay'); legend('show','Location','best'); grid on;
ylim([0, max(perm_importance(:))*0.1]);
sgtitle('几何边界条件敏感性曲线（原始/平滑）');

figure('Color','w','Position',[100 100 1150 460]);
subplot(1,3,1); hold on;
for i = 1:length(elec_idx)
    plot(1:n_times, perm_importance(elec_idx(i),:), '-o', 'LineWidth',2, 'DisplayName',elec_names{i});
end
xlabel('时序点','FontSize',12); ylabel('敏感性','FontSize',12);
title('电阻率-原始'); legend('show','Location','best'); grid on;
ylim([0, max(perm_importance(:))*1.1]);

subplot(1,3,2); hold on;
for i = 1:length(elec_idx)
    plot(1:n_times, perm_importance_movmean(elec_idx(i),:), '-o', 'LineWidth',2, 'DisplayName',elec_names{i});
end
xlabel('时序点','FontSize',12); ylabel('敏感性','FontSize',12);
title('电阻率-滑动平均'); legend('show','Location','best'); grid on;
ylim([0, max(perm_importance(:))*1.1]);

subplot(1,3,3); hold on;
for i = 1:length(elec_idx)
    plot(1:n_times, perm_importance_sgolay(elec_idx(i),:), '-o', 'LineWidth',2, 'DisplayName',elec_names{i});
end
xlabel('时序点','FontSize',12); ylabel('敏感性','FontSize',12);
title('电阻率-Savitzky-Golay'); legend('show','Location','best'); grid on;
ylim([0, max(perm_importance(:))*1.1]);
sgtitle('电阻率边界条件敏感性曲线（原始/平滑）');

%% 可选：保存分析结果
save('permutation_grouped_sensitivity.mat','perm_importance','perm_importance_movmean','perm_importance_sgolay','geo_idx','elec_idx','param_names','perm_importance_raw','timeslog');
