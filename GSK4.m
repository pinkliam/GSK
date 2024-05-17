%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gaining-Sharing Knowledge Based Algorithm for Solving Optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%实例函数 求解最小值

%%
% 完成：当代的更新不要和当代的数据混用，全部使用上一代的数据；
% 改进排序(按照适应度)的问题，只需要适应度排序的下标位置（用于更新），种群的个体位置不需要变化。
% 种群是否重新排序（计算适应度）对后面的更新没有关系（个体之间没有关联，关联是当前个体的前后适应度个体，其他的的没有关联），对算法没有影响

clc;
clear all;

format long;
Alg_Name='GSK';

%% GSK参数定义
problemsize_n = 2;     % 问题维度
pop_size = 100;     % 种群数目
iter_max = 50;  % 最大迭代次数
run_time = 100; %运行次数
Kf = 0.5;  % 知识因素参数
Kr = 0.9;  % 知识比率
K = 5;    % 知识学习率
p = 0.1;    %高级阶段种群分成三类时使用 最佳，中等，最差 p, 1-2p, p
max_region = 10.0;  % 参数范围
min_region = -10.0;
% lu = [min_region * ones(1, problemsize_n); max_region * ones(1, problemsize_n)]; % 参数上下边界矩阵
lu = [-3, 4.1; 12.1, 5.8]
func = @test_func; % 测试函数
run_fitness = inf(run_time,1);
run_var = inf(run_time, problemsize_n);
run_best_fitness = inf;
run_best_var = inf(1,problemsize_n); % 全局最优变量
run_mean_fitness = inf(run_time,1);
all_best_fitness = inf(iter_max, run_time); % 所有迭代的最优值

for run = 1:run_time
    fprintf("run:%d--------------------------------\n", run);
    % 定义适应度矩阵
    fitness = inf(pop_size, 1);
    fitness_new = inf(pop_size, 1);
    fitness_sorted = zeros(pop_size, 1);
    % 暂存更新后的新个体
    pop_new = zeros(pop_size,problemsize_n);
    
    %存放最优数据
    iter_best_fitness = inf(iter_max, 1);
    best_fitness = inf;
    iter_best_var = inf(iter_max, problemsize_n);
    best_var = inf(1, problemsize_n);
    best_func = inf;
    
    
    %% 初始化种群
    % popold = repmat(min_region * ones(1, problemsize_n), pop_size, 1) + rand(pop_size, problemsize_n) .* repmat((max_region-min_region) * ones(1, problemsize_n), pop_size, 1);
    popold = rand(pop_size, problemsize_n).*ones(pop_size, problemsize_n).*repmat((lu(1,:)-lu(2,:)), pop_size, 1) + repmat(lu(2,:), pop_size, 1)
    pop = popold; % 行数表示种群数，列数表示问题维度
    
    %% 循环迭代
    for iter = 1:iter_max
        % 问题的初高级维度
        problemsize_junior = fix(problemsize_n * (1-iter/iter_max)^K); 
        problemsize_senior = problemsize_n - problemsize_junior;
        % 计算适应度，使用函数值为适应度
        for i = 1:pop_size
            fitness(i) = func(pop(i, :));
        end
        % 按照适应度排序,降序
        [fitness_sorted, originalIndices] = sort(fitness, "ascend");
        for k = 1:pop_size
            pop_sorted(k, :) = pop(originalIndices(k), :); 
        end
    
        pop = pop_sorted;
        
     
        % 更新，低阶段 高阶段更新公式
        % 初高级应该都是pop_size个并且都是基于上一次的数据进行更新，对于当次的数据不能使用
        for i = 1:pop_size
    
            % 低维度（低级阶段更新）
            pop_new_1 = Gained_Shared_Junior(pop, problemsize_junior, i, Kr, Kf, fitness);
            % 判断是否超出设置范围
            pop_new_1 = boundary(pop_new_1, pop(i,:), lu);
    
            % 高维度更新
            pop_new_2 = Gained_Shared_Senior(pop, problemsize_junior, Kr, Kf, i, p, fitness);
            % 判断是否超出设置范围
            pop_new_2 = boundary(pop_new_2, pop(i,:), lu);
            % 更新
            pop_new(i,:) = [pop_new_1(1:problemsize_junior) pop_new_2(problemsize_junior+1:problemsize_n)];
            % 适应度优于原来的则替换
            fitness_new(i) = func(pop_new(i,:));      
        end 
        % 计算新个体适应度，判断是否替换原个体（上一次迭代） 
        for i = 1:pop_size
            if fitness_new(i) < fitness(i)
                pop(i,:) = pop_new(i,:);
            end
        end
        % 计算适应度
        for i = 1:pop_size
            fitness(i) = func(pop(i, :));
        end
        [minValue, minIndex] = min(fitness);
        % 保存本次迭代最优数据
        iter_best_var(iter,:) = pop(minIndex, :);
        iter_best_fitness(iter) = minValue;
        % 更新全局最优数据
        if minValue < best_fitness
            best_var = iter_best_var(iter,:);
            best_fitness = minValue;
            best_func = best_fitness;
        end
    % pause(0.1) % 停顿0.1S
    fprintf("iter:%d\n", iter);
    % disp(iter)
    all_best_fitness(iter, run) = best_fitness;
    end % iter end
    % 本次run的所有iter的fitness的均值
    run_mean_fitness(run) = mean(iter_best_fitness);
    % 更新run最优数据
    run_fitness(run) = best_fitness;
    run_var(run,:) = best_var;
    if run_fitness(run) < run_best_fitness
        run_best_fitness = run_fitness(run);
        run_best_var(1,:) = run_var(run,:);
    end
end % run_time end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 误差 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runfitness_mean = mean(run_fitness);
variance_fitness = run_fitness-runfitness_mean*ones(run_time, 1).^2; % 方差
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 绘图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('X-run');  
ylabel('Y-run_fitness');  
h1 = plot(1:1:run_time, run_fitness, "r", "MarkerSize", 10);
title('run最适应度变化曲线');  
grid on;
hold on;
h2 = plot(1:1:run_time, runfitness_mean*ones(run_time, 1), "b", "MarkerSize", 10);
legend([h1, h2],"run_fitness", "runfitness_mean");

figure;
xlabel('X-run');  
ylabel('Y-variance_fitness');  
h3 = plot(1:1:run_time, variance_fitness, "r", "MarkerSize", 10);
title('variance_fitness方差)');  
grid on;
legend(h3,"variance_fitness");

figure;
xlabel('X-run');  
ylabel('Y-run-1-bestfitness');  
h3 = plot(1:1:iter_max, all_best_fitness(:, 1), "r", "MarkerSize", 10);
title('以第一次运行（run）为例最优迭代适应度变化');  
grid on;
legend(h3,"variance_fitness");

% grid on;
% hold on; % 保持图片显示 







