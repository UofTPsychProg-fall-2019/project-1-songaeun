%% Make Random Pairs
clear all

pairInfo = struct;

n_cat = 70;
n_mem = 10;
l_idx = randperm(n_cat*n_mem);
p_idx = [(1:1:n_cat*n_mem)', l_idx'];

save('pair_idx.mat', 'p_idx');