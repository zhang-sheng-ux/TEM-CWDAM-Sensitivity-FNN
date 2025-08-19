%% 区间平均+多次重复+美化三角热力图的参数对Permutation敏感性分析（全时窗，不分时段）
clear; clc;
load('normalized_data.mat');

param_names = {... 
    '$b$', ...                 % 坡比
    '$H$', ...                 % 坝高
    '$b_c$', ...               % 心墙坡比
    '$H_w$', ...               % 上游水位
    '$\rho_d$', ...            % 坝体电阻率
    '$\rho_f$', ...            % 坝基电阻率
    '$\rho_c$', ...            % 心墙电阻率
    '$\rho_w$'};               % 水体电阻率

Np = length(param_names);
n_samples = length(normalized_data);
n_times = length(normalized_data(1).Bz_log);

X = zeros(n_samples, Np);
Y = zeros(n_samples, n_times);
for i = 1:n_samples
    X(i,:) = normalized_data(i).X_norm;
    Y(i,:) = normalized_data(i).Bz_log';
end

% ====== 1. 全时窗索引 ======
tidx = 1:n_times;   % 全部时间点

% ====== 2. 多次Permutation + 进度显示 ======
repeats = 5;
AB_matrix = zeros(Np, Np);  % 只需一组

total_iter = repeats * Np * Np;
iter = 0;

AB_tmp = zeros(Np, Np, repeats);
for rep = 1:repeats
    for i = 1:Np
        for j = 1:Np
            ab_list = zeros(length(tidx),1);
            for t = 1:length(tidx)
                y_true = Y(:, tidx(t));
                model = TreeBagger(100, X, y_true, 'Method', 'regression', 'MinLeafSize', 10);
                ref_corr = corr(predict(model, X), y_true);

                Xp = X;
                Xp(:,i) = X(randperm(n_samples), i);
                Xp(:,j) = X(randperm(n_samples), j);
                ab_list(t) = ref_corr - corr(predict(model, Xp), y_true);
            end
            AB_tmp(i,j,rep) = mean(ab_list);

            % 进度显示
            iter = iter + 1;
            if mod(iter,20)==0 || (i==Np && j==Np && rep==repeats) % 每20步输出一次，最后一步也输出
                fprintf('进度：%d/%d (repeat%d/%d, 参数对(%d,%d)/(%d,%d))\n', ...
                    iter, total_iter, rep, repeats, i, j, Np, Np);
            end
        end
    end
end
AB_matrix = mean(AB_tmp, 3);

% ====== 3. 热力图美化（下三角有效区，上半区白色） ======
figure('Color','w','Position',[100 100 600 550]);
mat = AB_matrix;

% 仅下三角区显示数据，上三角置NaN
mat_tri = tril(mat, -1); 
mat_tri(mat_tri==0) = NaN;
imagesc(mat_tri);
colormap([1 1 1; jet(256)]);
colorbar;
clim = [min(mat_tri(~isnan(mat_tri))), max(mat_tri(~isnan(mat_tri)))];
if isnan(clim(1)), clim=[0 1]; end
caxis(clim);

set(gca,'XTick',1:Np,'XTickLabel',param_names,'YTick',1:Np,'YTickLabel',param_names,'FontSize',13);
xlabel('参数2','FontSize',15); ylabel('参数1','FontSize',15);
title('AB敏感性下三角热力图（全时窗）', 'FontSize',16);

% 仅在下三角区标注
for i = 2:Np
    for j = 1:i-1
        val = mat(i,j);
        if ~isnan(val) && abs(val)>0.001
            text(j,i,sprintf('%.2f',val),'HorizontalAlignment','center','Color','w','FontSize',12,'FontWeight','bold');
        end
    end
end

%% 保存结果
save('AB_pairwise_triangle_heatmap_allwindow.mat','AB_matrix','param_names');
