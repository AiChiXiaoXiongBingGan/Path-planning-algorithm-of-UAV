function particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun)
for i = 1:size(particles,2)
    
    % 利用三次样条拟合散点
    x_seq=[startPos(1), particles(i).pos.x, goalPos(1)];
    y_seq=[startPos(2), particles(i).pos.y, goalPos(2)];
    z_seq=[startPos(3), particles(i).pos.z, goalPos(3)];
    
    k = length(x_seq);
    i_seq = linspace(0,1,k);
    I_seq = linspace(0,1,100);
    X_seq = spline(i_seq,x_seq,I_seq);
    Y_seq = spline(i_seq,y_seq,I_seq);
    Z_seq = spline(i_seq,z_seq,I_seq);
    path = [X_seq', Y_seq', Z_seq'];
    
    % 判断生成的曲线是否与与障碍物相交
    flag = 0;
    for j = 2:size(path,1)
        x = path(j,1);
        y = path(j,2);
        z_interp = interp2(X,Y,Z,x,y);
        distance1 = sqrt((x-radar(1))^2+(y-radar(2))^2);
        distance2 = sqrt((x-H_gun(1))^2+(y-H_gun(2))^2);
        if path(j,3) < z_interp % 避开山峰范围
            flag = 1;
            break
        elseif (x < 0)||(x > 100)   % 限制规划路径范围
            flag = 1;
            break
        elseif (y < 0)||(y > 100)   % 限制规划路径范围
            flag = 1;
            break
        elseif (path(j,3) < 0)||(path(j,3) > 100)   % 限制规划路径范围
            flag = 1;
            break
        elseif (path(j,3) > h_ocean)&&(distance1 < radar(3)) % 避开雷达范围
            flag = 1;
            break
        elseif (path(j,3) > h_ocean)&&(distance2 < H_gun(3)) % 避开高炮范围
            flag = 1;
            break
        end
    end  
       

    %% 分别计算水上与水下的路径点
    [~,Z_index] = find_nearest(Z_seq,h_ocean);
    X_seq_down = X_seq(1:Z_index);
    X_seq_up = X_seq(Z_index:numel(X_seq));
    Y_seq_down = Y_seq(1:Z_index);
    Y_seq_up = Y_seq(Z_index:numel(Y_seq));
    Z_seq_down = Z_seq(1:Z_index);
    Z_seq_up = Z_seq(Z_index:numel(Z_seq));    
    
    %% 计算三次样条得到的离散点的路径长度（适应度）
    dx_down = diff(X_seq_down);
    dy_down = diff(Y_seq_down);
    dz_down = diff(Z_seq_down);
    fitness_down = sum(sqrt(dx_down.^2 + dy_down.^2 + dz_down.^2));
    
    dx_up = diff(X_seq_up);
    dy_up = diff(Y_seq_up);
    dz_up = diff(Z_seq_up);
    fitness_up = sum(sqrt(dx_up.^2 + dy_up.^2 + dz_up.^2));
    
    fitness = fitness_down*d_ocean + fitness_up*d_air;
    if flag == 1
        %若flag=1,表明此路径将与障碍物相交，则增大适应度值
        particles(i).fitness = 1000*fitness;
        particles(i).path = path;
    else
        %否则，表明可以选择此路径
        particles(i).fitness = fitness;
        particles(i).path = path;
    end
 end
end