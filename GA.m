%%%%%%%%%%%%%%%%%%%%%%%%%%%% GSK AND GA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output = 8*sin(5*pop(1)) + 3*cos(pop(length(pop))) + (3*sin(pop(length(pop))))^3 
% 函数最小值
%% 清空工作区 
% 比较GSK和GA 还没有编写完成

clc
clear all;

%% GA算法参数定义
popsize = 100;               % 种群大小
chromlength = 20;           % 二进制编码长度
p_cross = 0.7;              % 交叉概率
p_mutation = 0.1;          % 变异概率
iter_max = 50;             % 最大迭代次数
bestfit = inf;             % 初始化适应度值为∞
bestindividual = 0;         % 初始化最优解
result = zeros(2,iter_max); % 对存储每轮迭代最优解的result矩阵预分配内存,提高运行速度
%% 初始化种群
pop = round(rand(popsize,chromlength));  
% rand函数用0~1之间的随机数生成了一个popsize行,chromlength列的矩阵
% round函数将此矩阵四舍五入为0或1的整数

%% 循环迭代
for iter = 1:iter_max
    % 1.首先将二进制转为十进制
    [px,py] = size(pop);                    % 种群的行列数
    for j = 1:py
        pop1(:,j) = pop(:,j) * 2^(py-j);    % 按位权值展开
    end
    temp = sum(pop1,2);                     % 行求和sum(*,2)
    pop2 = 0+temp*((10-0)/2^chromlength);

    % 2.计算函数目标值
    fitvalue = 10*sin(5*pop2)+7*abs(pop2-5)+10;

 
    for i = 1:2:px-1 % 让i与i+1进行交叉,所以i遍历染色体中编号为奇数的就可以了
        if rand < p_cross
            point = round(rand * py);   % 在py位二进制数中随机选一个交叉点位
            newpop2(i,:) = [newpop(i,1:point),newpop(i+1,point+1:end)];
            newpop2(i+1,:) = [newpop(i+1,1:point),newpop(i,point+1:end)];
        else
            newpop2(i,:) = newpop(i,:);
            newpop2(i+1,:) = newpop(i+1,:);
            % 一定几率不发生交叉
        end
    end
    
    % 5.变异操作
    for i = 1:px
        if rand < p_mutation                    % 参数定义时的变异概率
            mutation_point = round(rand*py);   % 发生变异时的点位
            if mutation_point <= 0
                mutation_point = 1;             % 检测越界
            end
            newpop3(i,:) = newpop2(i,:);        % 变异后的种群存储在newpop3矩阵中
            if newpop3(i,mutation_point) == 0   % 将变异点位上的二进制数取反
                newpop3(i,mutation_point) = 1;
            else
                newpop3(i,mutation_point) = 0;
            end
        else                                    % p_mutation设置为一个很小的数
            newpop3(i,:) = newpop2(i,:);        % 大部分newpop2都没有发生变异
        end
    end

    % 6.更新种群,重新计算种群的适应度,更新Best记录
    pop = newpop3;
    % 和第一步时一样,先将二进制转换为十进制,计算出小分划区间中的实数值
    [px,py] = size(pop);
    for j = 1:py
        pop1(:,j) = 2^(py-j) * pop(:,j); % 二进制数按位权值展开
    end  % chromlength位二进制数能表示的十进制数范围为[0,2^chromlength-1]
    temp = sum(pop1,2);     % 按位权展开的十进制数行求和
    pop2 = 0 + ((10 - 0)/2^chromlength) * temp; % 将小分划的编号映射为定义域里的实数值

    fitvalue = 10*sin(5*pop2)+7*abs(pop2-5)+10; 
    % 将pop2矩阵代入目标函数计算适应度

    for i = 1:px
        if bestfit < fitvalue(i)
            bestfit = fitvalue(i);      % 找到本轮迭代的最优f(x)
            bestindividual = pop2(i);   % 找到本轮迭代的最优x
        end
    end

    result(1,iter) = bestindividual;    % result矩阵第1行存储每轮迭代的最优x
    result(2,iter) = bestfit;           % result矩阵第2行存储每轮迭代的最优f(x)
    plot(result(1,iter),result(2,iter),'b*','MarkerSize',5)
    title(strcat('当前迭代代数:',num2str(iter)));
    pause(0.03);
end

plot(result(1,end),result(2,end),'r*','MarkerSize',10);
grid on
hold off
fprintf(['The best x is ---> \t',num2str(bestindividual), ...
    '\nThe fitness value is --->',num2str(bestfit),'\n']);





