function particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun)
for i = 1:size(particles,2)
    
    % ���������������ɢ��
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
    
    % �ж����ɵ������Ƿ������ϰ����ཻ
    flag = 0;
    for j = 2:size(path,1)
        x = path(j,1);
        y = path(j,2);
        z_interp = interp2(X,Y,Z,x,y);
        distance1 = sqrt((x-radar(1))^2+(y-radar(2))^2);
        distance2 = sqrt((x-H_gun(1))^2+(y-H_gun(2))^2);
        if path(j,3) < z_interp % �ܿ�ɽ�巶Χ
            flag = 1;
            break
        elseif (x < 0)||(x > 100)   % ���ƹ滮·����Χ
            flag = 1;
            break
        elseif (y < 0)||(y > 100)   % ���ƹ滮·����Χ
            flag = 1;
            break
        elseif (path(j,3) < 0)||(path(j,3) > 100)   % ���ƹ滮·����Χ
            flag = 1;
            break
        elseif (path(j,3) > h_ocean)&&(distance1 < radar(3)) % �ܿ��״ﷶΧ
            flag = 1;
            break
        elseif (path(j,3) > h_ocean)&&(distance2 < H_gun(3)) % �ܿ����ڷ�Χ
            flag = 1;
            break
        end
    end  
       

    %% �ֱ����ˮ����ˮ�µ�·����
    [~,Z_index] = find_nearest(Z_seq,h_ocean);
    X_seq_down = X_seq(1:Z_index);
    X_seq_up = X_seq(Z_index:numel(X_seq));
    Y_seq_down = Y_seq(1:Z_index);
    Y_seq_up = Y_seq(Z_index:numel(Y_seq));
    Z_seq_down = Z_seq(1:Z_index);
    Z_seq_up = Z_seq(Z_index:numel(Z_seq));    
    
    %% �������������õ�����ɢ���·�����ȣ���Ӧ�ȣ�
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
        %��flag=1,������·�������ϰ����ཻ����������Ӧ��ֵ
        particles(i).fitness = 1000*fitness;
        particles(i).path = path;
    else
        %���򣬱�������ѡ���·��
        particles(i).fitness = fitness;
        particles(i).path = path;
    end
 end
end