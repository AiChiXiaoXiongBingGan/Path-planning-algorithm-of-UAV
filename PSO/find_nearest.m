function [Z_min,Z_index] = find_nearest(Z_seq,h_ocean)

%找到单次路径规划点中与海洋深度值最近的点、索引值

[Z_min,Z_index] = min(abs(Z_seq-h_ocean));


end

