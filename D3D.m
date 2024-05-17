%%　3维立体图
clear;clc; %清除前置数据

%数据预处理
x = linspace(0,1,50); %设置x轴的范围
y = x; %设置y轴范围
[X,Y] = meshgrid(x,y); %将其x，y轴网格化
Z = 1-sqrt((X).^2+(Y-1).^2); %直接计算

%绘制曲面
Fig = mesh(X,Y,Z); %绘制三维曲面图