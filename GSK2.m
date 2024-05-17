%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gaining-Sharing Knowledge Based Algorithm for Solving Optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 初级阶段：
%    即低维度，更新公式
% 高级阶段：
%    （p 1-2p p）*pop 三部分群体
%    即高维度，更新公式

%实例函数 求解最值
%%

% 重点改进：更新时要具体个体的具体的某维度的具体位置进行更新；
% 完成：当代的更新不要和当代的数据混用，全部使用上一代的数据；

clc;
clear all;

format long;
Alg_Name='GSK';

%% GSK参数定义
problemsize_n = 50;     % 问题维度
pop_size = 100;     % 种群数目
iter_max = 100;  % 最大迭代次数
Kf = 0.5;  % 知识因素参数
Kr = 0.9;  % 知识比率
K = 5;    % 知识学习率
p = 0.1;    %高级阶段种群分成三类时使用 最佳，中等，最差 p, 1-2p, p
max_region = 10.0;  % 参数范围
min_region = -10.0;
lu = [min_region * ones(1, problemsize_n); max_region * ones(1, problemsize_n)]; % 参数上下边界矩阵
func = @test_func; % 测试函数

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
popold = repmat(min_region * ones(1, problemsize_n), pop_size, 1) + rand(pop_size, problemsize_n) .* repmat((max_region-min_region) * ones(1, problemsize_n), pop_size, 1);
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

% 停顿0.1S
% pause(0.1)
disp(iter)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 误差 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i = 1:pop_size
%     mean = mean(iter_best_fitness(i))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 绘图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%     % plot(best_fitness,'r*','MarkerSize',10);
%     % % plot3(best_var(1), best_var(2), best_func, "r", 'MarkerSize',10)
%     % grid on;
%     % hold off;
% 
%     % scatter(iter, iter_best_var(1)); % 绘制散点图  
%     xlabel('X-iter');  
%     ylabel('Y-iter_best_var(1)');  
%     plot(iter, iter_best_var(1), "y", "MarkerSize", 10);
%     title('最优量（1）变化曲线');  
%     grid on;
%     hold off; 


xlabel('X-iter');  
ylabel('Y-iter_best_fitness');  
plot(1:1:iter, iter_best_fitness, "r", "MarkerSize", 10);
title('最适应度变化曲线');  
grid on;
% hold on;

% xlabel('X-iter');  
% ylabel('Y-iter_best_fitness');  
% plot(1:1:iter, iter_best_var(1:1:iter, 1), "r", "MarkerSize", 10);
% title('最优变量（1）变化曲线');  
% grid on;
% hold on;

% xlabel('X-iter');  
% ylabel('Y-iter_best_var(2)');  
% plot(1:1:iter, iter_best_var(1:1:iter, 2), "r", "MarkerSize", 10);
% title('最优量（2）变化曲线');  
% grid on;
% hold on; % 保持图片显示 







