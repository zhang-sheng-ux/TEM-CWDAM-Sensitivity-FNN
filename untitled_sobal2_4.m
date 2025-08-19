clear; clc;
load('AB_pairwise_triangle_heatmap_timeseg5.mat'); 
% AB_matrices, param_names, t_labels, t_edges, t_idx_group

Np = length(param_names);
N_seg = length(t_labels);

for seg = 1:N_seg
    figure('Color','w','Position',[100 100 600 550]);
    mat = AB_matrices(:,:,seg);

    % 仅下三角
    mat_tri = tril(mat, -1); 
    mat_tri(mat_tri==0) = NaN; % 0为NaN

    % 先全部白底
    imagesc(NaN(Np-1,Np-1)); colormap([1 1 1; jet(256)]); hold on;

    % 灰色填充区域的RGB
    gray_fill = [0.85 0.85 0.85];
    % 画格子和填色（仅2:Np行，1:Np-1列）
for i = 2:Np
    for j = 1:i-1
        val = mat(i,j);
        if isnan(val), continue; end
        if abs(val)<0.01
            fill([j-0.5 j+0.5 j+0.5 j-0.5], [i-0.5 i-0.5 i+0.5 i+0.5], gray_fill, ...
                'EdgeColor',[0.7 0.7 0.7],'LineWidth',1.2);
            % 灰底一律用深灰文字
            text(j, i, '＜0.01', 'HorizontalAlignment', 'center', ...
                'Color', [0.3 0.3 0.3], 'FontSize', 12, 'FontWeight', 'bold');
        else
            cmap = jet(256);
            cmin = 0; cmax = 1;
            idx = round(1 + (val-cmin)/(cmax-cmin)*(size(cmap,1)-1));
            idx = max(1,min(idx,size(cmap,1)));
            thiscolor = cmap(idx,:);
            fill([j-0.5 j+0.5 j+0.5 j-0.5], [i-0.5 i-0.5 i+0.5 i+0.5], thiscolor, ...
                'EdgeColor',[0.7 0.7 0.7],'LineWidth',1.2);

            % 判断色块亮度
            Y = 0.299*thiscolor(1) + 0.587*thiscolor(2) + 0.114*thiscolor(3);
            if Y > 0.6
                textcolor = 'k'; % 浅色底用黑字
            else
                textcolor = 'w'; % 深色底用白字
            end
            text(j, i, sprintf('%.2f',val), 'HorizontalAlignment', 'center', ...
                'Color', textcolor, 'FontSize', 12, 'FontWeight', 'bold');
        end
    end
end

    % 设置坐标轴和标签（对应的范围和标签）
    set(gca, ...
        'XTick', 1:Np-1, ...
        'XTickLabel', param_names(1:Np-1), ...
        'YTick', 2:Np, ...
        'YTickLabel', param_names(2:Np), ...
        'TickLabelInterpreter', 'latex', ...
        'FontSize', 13, ...
        'LineWidth',1.5, ...
        'XColor','k', ...
        'YColor','k');
    xlabel('Parameter 2','FontSize',15);
    ylabel('Parameter 1','FontSize',15);
    title(['Pairwise AB Sensitivity, ' t_labels{seg}], ...
        'Interpreter', 'latex', 'FontSize', 16);

    % 去掉右框线和上框线
    ax = gca;
    ax.Box = 'off';
    ax.TickDir = 'out';
    ax.XColor = 'k'; ax.YColor = 'k';
    ax.TickLabelInterpreter = 'latex';

    % 坐标轴范围更紧凑
    axis([0.5 Np-0.5 1.5 Np+0.5]);
    axis square;

    hold off;
    cb = colorbar('Ticks',linspace(0,1,5),...
        'TickLabels',arrayfun(@(x) sprintf('%.2f',x), linspace(0,1,5),'UniformOutput',false));
    caxis([0,1]);
    cb.TickDirection = 'out';
end
