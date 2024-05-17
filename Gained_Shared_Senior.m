%% 高级阶段
function[pop_new_senior] = Gained_Shared_Senior(pop, problemsize_junior, Kr, Kf, pop_current, p, fitness)

[pop_size, problemsize_n] = size(pop);
pop_new_senior = zeros(1,problemsize_n);
for j = problemsize_junior+1:problemsize_n
    if rand <= Kr
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%随机数要不要固定一个种子
        % 在最佳、中等、最差个体中各确定一个随机个体
        random_pop_best = randi(fix(pop_size*p));
        random_pop_middle = fix(pop_size*p) + randi(pop_size-fix(pop_size*p)*2);
        random_pop_worst = pop_size - randi(fix(pop_size*p));
        if fitness(pop_current) > test_func(pop(random_pop_middle, :))
            pop_new_senior(j) = pop(pop_current, j) + Kf*( (pop(random_pop_best, j)-pop(random_pop_worst, j)) + (pop(random_pop_middle, j)-pop(pop_current, j)) );
        else
            pop_new_senior(j) = pop(pop_current, j) + Kf*( (pop(random_pop_best, j)-pop(random_pop_worst, j)) + (pop(pop_current, j)-pop(random_pop_middle, j)) );
        end
    else
        pop_new_senior(j) = pop(pop_current, j);
    end 
end

end