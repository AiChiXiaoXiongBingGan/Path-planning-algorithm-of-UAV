function [Z_min,Z_index] = find_nearest(Z_seq,h_ocean)

%�ҵ�����·���滮�����뺣�����ֵ����ĵ㡢����ֵ

[Z_min,Z_index] = min(abs(Z_seq-h_ocean));


end

