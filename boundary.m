function pop_new = boundary(JuniorOrSenior, pop_old, lu)
% 超出设置范围则用上一迭代值和边界值的中值

ind_l = JuniorOrSenior < lu(1,:); % 找出具体的维超出下边界
ind_u = JuniorOrSenior > lu(2,:); % 找出具体的维超出上边界
% check the lower bound
if sum(ind_l)
    JuniorOrSenior(ind_l) = (pop_old(ind_l)+lu(1,ind_l))/2;
end
% check the upper bound
if sum(ind_u)
    JuniorOrSenior(ind_u) = (pop_old(ind_u)+lu(2, ind_u))/2;
end
pop_new = JuniorOrSenior;
end
% 在此处不好分辨低高维的位置那就不分，在主函数再切割拼接即可