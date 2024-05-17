%%
% 测试知识比率不同时的初高级迭代次数的变化情况

%%
n = 50; % 迭代次数
problemsize = 30;
res = zeros(n,2);
K = 0.5
for i = 1:n
    res(i,:) = [i,problemsize*(1-i/50)^K];
end
% 这是初级维度的变化情况
plot(1:n, res(:, 2));