function T_position = GetRandomTargetPosition(n_category, n_memitem, n_target)
% To get position of targets from the entire sequence of image presentation. 
% 1 = target, 0 = nontarget(memory item)

    n_all = n_category * (n_memitem + n_target);
    T_position = zeros(n_all, 1);
    tar_pos = randperm(n_all, n_category*n_target);
    T_position(tar_pos) = 1; % 0_memory item, 1_memory item    

end

