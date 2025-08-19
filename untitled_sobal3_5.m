clear; clc;
load('normalized_data.mat');

% -------- 固定参数组合表 --------
n_layers = 2;
n_neurons = 20;
act_funs = {'tansig', 'logsig'};
train_algs = {'trainlm', 'trainbr'};

n_exp = numel(act_funs) * numel(train_algs);

% -------- 数据准备 --------
n_samples = length(normalized_data);
Np = 8;
n_times = length(normalized_data(1).Bz_log);

X_norm = zeros(n_samples, Np);
Y = zeros(n_samples, n_times);
time = normalized_data(1).time(:);

for i = 1:n_samples
    X_norm(i,:) = normalized_data(i).X_norm(:)';
    Y(i,:)      = normalized_data(i).Bz_log(:)';
end

log_time = log10(time);
norm_log_time = (log_time - min(log_time)) / (max(log_time) - min(log_time));

X_all = [];
Y_all = [];
for s = 1:n_samples
    for t = 1:n_times
        X_all = [X_all; X_norm(s,:), norm_log_time(t)];
        Y_all = [Y_all; Y(s,t)];
    end
end

X_min = min(X_all);
X_max = max(X_all);
X_all_norm = (X_all - X_min) ./ (X_max - X_min);

n_total = size(X_all_norm,1);
rng(42);
idx = randperm(n_total);
n_train = round(0.8*n_total);

X_train = X_all_norm(idx(1:n_train), :)';
Y_train = Y_all(idx(1:n_train))';
X_test  = X_all_norm(idx(n_train+1:end), :)';
Y_test  = Y_all(idx(n_train+1:end))';

% -------- 结果表 --------
Result = table('Size',[n_exp, 7], ...
    'VariableTypes',{'string','string','double','double','double','double','double'}, ...
    'VariableNames',{'Activation','Algorithm','NumLayers','NumNeurons','MSE','R2','Time'});

% -------- 组合实验 --------
expi = 0;
for i = 1:numel(act_funs)
    for j = 1:numel(train_algs)
        expi = expi + 1;
        act_fun = act_funs{i};
        train_alg = train_algs{j};

        % 构建网络
        net = fitnet(repmat(n_neurons,1,n_layers), train_alg);
        for k = 1:n_layers
            net.layers{k}.transferFcn = act_fun;
        end
        net.trainParam.epochs    = 1000;
        net.trainParam.goal      = 1e-5;
        net.trainParam.max_fail  = 20;
        net.divideParam.trainRatio = 0.8;
        net.divideParam.valRatio   = 0.2;
        net.divideParam.testRatio  = 0;

        % 训练与计时
        fprintf('[%s] Test %d/%d | Act: %s | Alg: %s\n', ...
            datestr(now,'HH:MM:SS'), expi, n_exp, act_fun, train_alg);
        tic;
        [net,~] = train(net, X_train, Y_train);
        t_used = toc;

        % 测试集性能
        Y_pred = net(X_test);
        mse_test = mean((Y_pred-Y_test).^2);
        R2 = 1 - sum((Y_test-Y_pred).^2)/sum((Y_test-mean(Y_test)).^2);

        % 记录
        Result.Activation(expi) = string(act_fun);
        Result.Algorithm(expi)  = string(train_alg);
        Result.NumLayers(expi)  = n_layers;
        Result.NumNeurons(expi) = n_neurons;
        Result.MSE(expi)        = mse_test;
        Result.R2(expi)         = R2;
        Result.Time(expi)       = t_used;

        fprintf('   --> MSE = %.6f | R2 = %.4f | Time = %.2fs\n', mse_test, R2, t_used);
    end
end

disp(Result);
writetable(Result,'nn_fixed2layer15_compare.csv');
