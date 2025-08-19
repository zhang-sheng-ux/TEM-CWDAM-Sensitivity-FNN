%% -------- 1. 数据加载与整理 --------神经网络，预测使用，生成预测模型。
clear; clc;
load('normalized_data.mat');  % 加载结构体

n_samples = length(normalized_data);     % 样本数量
Np = 8;
n_times = length(normalized_data(1).Bz_log); % 时序点数

% 组装数据
X_real = zeros(n_samples, Np);   % 真实工况参数
X_norm = zeros(n_samples, Np);   % 归一化参数
Y = zeros(n_samples, n_times);   % 响应(log(Bz))
time = normalized_data(1).time(:); % 时间序列 (n_times × 1)

for i = 1:n_samples
    X_real(i,:) = normalized_data(i).X_raw(:)';
    X_norm(i,:) = normalized_data(i).X_norm(:)';
    Y(i,:)      = normalized_data(i).Bz_log(:)';
end

% ---- 归一化“对数时间” ----
log_time = log10(time);  % time 必须全为正数
norm_log_time = (log_time - min(log_time)) / (max(log_time) - min(log_time)); % 归一到[0,1]

%% -------- 2. 神经网络建模 (fitnet) --------
X_all = [];
Y_all = [];
for s = 1:n_samples
    for t = 1:n_times
        X_all = [X_all; X_norm(s,:), norm_log_time(t)];
        Y_all = [Y_all; Y(s,t)];
    end
end

% 对全部输入再做归一化（防止某些参数分布窄，时间跨度大），可选
X_min = min(X_all);
X_max = max(X_all);
X_all_norm = (X_all - X_min) ./ (X_max - X_min);

% 划分训练/测试集
n_total = size(X_all_norm,1);
rng(42);
idx = randperm(n_total);
n_train = round(0.8*n_total);

X_train = X_all_norm(idx(1:n_train), :)';
Y_train = Y_all(idx(1:n_train))';
X_test  = X_all_norm(idx(n_train+1:end), :)';
Y_test  = Y_all(idx(n_train+1:end))';

% 建立神经网络
net = fitnet([15 15],'trainlm');
net.trainParam.epochs = 1000;
net.trainParam.goal = 1e-5;
net.trainParam.max_fail = 20;
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0;
[net,~] = train(net, X_train, Y_train);

%% -------- 3. 测试集性能评估 --------
Y_pred_test = net(X_test);
mse_test = mean((Y_pred_test-Y_test).^2);
fprintf('测试集MSE: %.5f\n', mse_test);

figure('Color','w','Position',[100 100 800 600]);
subplot(2,1,1);
scatter(Y_test, Y_pred_test, 40, 'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
hold on;
plot([min(Y_test),max(Y_test)],[min(Y_test),max(Y_test)],'r--','LineWidth',1.2);
xlabel('真实值 log(B_z)');
ylabel('预测值 log(B_z)');
title('测试集散点对比');
grid on; axis square;

subplot(2,1,2);
residuals = Y_pred_test - Y_test;
scatter(Y_test, residuals, 40, 'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
hold on; plot([min(Y_test),max(Y_test)], [0 0], 'r--');
xlabel('真实值 log(B_z)');
ylabel('残差');
title('测试集残差分布');
grid on;

%% -------- 4. 已知工况真实vs预测曲线（横坐标为真实time） --------
i_known = 5;   % 任选某组工况（1~n_samples）
X_known_real = X_real(i_known,:); % 真实参数
X_known_norm = X_norm(i_known,:); % 归一参数
Y_true = Y(i_known,:)';           % 真实曲线

% 预测（输入为归一参数+归一对数时间）
X_pred = [repmat(X_known_norm, n_times, 1), norm_log_time(:)];
X_pred_norm = (X_pred - X_min) ./ (X_max - X_min);
Y_pred = net(X_pred_norm')';

figure('Color','w','Position',[100 100 800 500]);
subplot(2,1,1);
plot(time, Y_true, 'ko-', 'LineWidth',2,'DisplayName','真实曲线'); hold on;
plot(time, Y_pred, 'r--s', 'LineWidth',2,'DisplayName','预测曲线');
set(gca, 'XScale', 'log');
xlabel('时间 / s');
ylabel('log_{10}(B_z)');
title(['已知工况：真实参数 = [', num2str(X_known_real, '%.2f '), ']']);
legend('show','Location','best'); grid on;

subplot(2,1,2);
plot(time, Y_pred-Y_true, 'b-o', 'LineWidth',2);
set(gca, 'XScale', 'log');
xlabel('时间 / s');
ylabel('预测误差');
title('预测误差（log_{10}空间）');
grid on;

%% -------- 5. 新工况预测（输入真实参数，自动归一化+预测） --------
% 例：自定义真实工况参数
X_new_real = [120, 1.8, 100, 1000, 0.5, 500, 30, 2000];

% 按训练归一化规则自动归一化
X_new_norm = X_new_real; % 先复制
X_new_norm(1) = X_new_real(1) / 150;         % 坝高[0,150]
X_new_norm(2) = 1 ./ X_new_real(2);          % 坡比[1,2.5]
X_new_norm(5) = X_new_real(5) / 1;           % 心墙坡比[0,1]
X_new_norm(7) = X_new_real(7) / 90;          % 上游水位[0,90]
log_cols = [3,4,6];
X_new_norm(log_cols) = log10(X_new_real(log_cols)) / 4;  % 电阻率参数
X_new_norm(8) = (log10(X_new_real(8)) + 2) / 5;

% 预测（同样输入归一对数时间）
X_pred_new = [repmat(X_new_norm, n_times, 1), norm_log_time(:)];
X_pred_new_norm = (X_pred_new - X_min) ./ (X_max - X_min);
Y_pred_new = net(X_pred_new_norm')';

figure('Color','w','Position',[100 100 700 400]);
plot(time, Y_pred_new, 'r-', 'LineWidth',2, 'DisplayName','新工况预测');
set(gca, 'XScale', 'log');
xlabel('时间 / s');
ylabel('log_{10}(B_z)');
title(['新工况预测曲线（真实参数 = [', num2str(X_new_real, '%.2f '), ']）']);
legend('show','Location','best'); grid on;

save('trained_net.mat', 'net', 'X_min', 'X_max', 'norm_log_time', 'time');


%% =========== END ===========

% 所有预测/展示曲线横坐标为真实 time，神经网络输入时间是对数归一化值。
