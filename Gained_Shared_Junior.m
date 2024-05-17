%% 初级阶段更新
function[pop_new_junior] = Gained_Shared_Junior(pop, problemsize_junior, pop_current, Kr, Kf, fitness)

[pop_size, problemsize_n] = size(pop); 
pop_new_junior = zeros(1,problemsize_n);
for j = 1:problemsize_junior
    if rand <= Kr
        random_pop = randi(pop_size);  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%随机数要不要固定一个种子
        % 要先判断j是不是第一个或者最后一个，更新公式不一样
        if (pop_current == 1) 
            R1 = 2;
            R2 = 3;             
        elseif pop_current== pop_size
            R1 = pop_size-2;
            R2 = pop_size-1;
        else 
            R1 = pop_current-1;
            R2 = pop_current+1;
        end         
        if fitness(pop_current) > test_func(pop(random_pop, :))
            pop_new_junior(j) = pop(pop_current, j) + Kf*( (pop(R1, j)-pop(R2, j)) + (pop(random_pop, j)-pop(pop_current, j)) );
        else
            pop_new_junior(j) = pop(pop_current, j) + Kf*( (pop(R1, j)-pop(R2, j)) + (pop(pop_current, j)-pop(random_pop, j)) );
        end

    else
        pop_new_junior(j) = pop(pop_current, j);
    end             

end
end