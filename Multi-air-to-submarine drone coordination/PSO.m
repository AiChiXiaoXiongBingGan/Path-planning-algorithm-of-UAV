function GlobalBest = PSO(startPos,goalPos) 

% startPos = [1, 1, 1];
% goalPos = [20, 40, 60];
% 随机定义山峰地图
mapRange = [100,100,100];              % 地图长、宽、高范围
[X,Y,Z] = defMap(mapRange);

% 定义海洋参数
h_ocean = 30;   %定义海洋深度
d_ocean = 1;    %海洋中航行能源消耗系数        
d_air = 1;      %大气中飞行能源消耗系数

% 定义威胁模型坐标
radar = [40 20 10];   %雷达威胁
H_gun = [70 70 10];   %高炮威胁坐标
biology = [60 20;80 30;10 60];    %水下不规则生物威胁坐标
air = [50 66];        %大气威胁坐标

%% 初始参数设置
N = 100;           % 迭代次数
M = 10;            % 粒子数量
pointNum = 3;      % 每一个粒子包含三个位置点
w = 1.2;           % 惯性权重
c1 = 2;            % 个体权重
c2 = 2;            % 社会权重

% 粒子位置界限
posBound = [[0,0,0]',mapRange'];

% 粒子速度界限
alpha = 0.1;
velBound(:,2) = alpha*(posBound(:,2) - posBound(:,1));
velBound(:,1) = -velBound(:,2);

%% 种群初始化
% 初始化每一代的最优粒子
GlobalBest.fitness = inf;
% while GlobalBest.fitness > 1000  % 保证初代群体中含有可行路径
    % 产生初始粒子
    particles = initPop(M,pointNum,startPos,goalPos);

    % 计算粒子适应度
    particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun);   

    % 更新全局最优粒子
    [particles,GlobalBest] = calBest(particles,GlobalBest);
% end

% % 生成雷达模型
% [x_radar,y_radar,z_radar] = sphere_threat(radar,h_ocean);
% 
% %  生成高炮模型
% [x_H_gun,y_H_gun,z_H_gun] = sphere_threat(H_gun,h_ocean);

% % 初始化每一代的最优适应度，用于画适应度迭代图
% fitness_beat_iters = zeros(N,1);

%% 主程序
% while GlobalBest.fitness > 1000
    for i = 1:N

        tic

        for j = 1:M  
            % 更新速度
            particles(j).v.x = w*particles(j).v.x ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.x-particles(j).pos.x) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.x-particles(j).pos.x);
            particles(j).v.y = w*particles(j).v.y ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.y-particles(j).pos.y) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.y-particles(j).pos.y);
            particles(j).v.z = w*particles(j).v.z ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.z-particles(j).pos.z) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.z-particles(j).pos.z);

            % 判断是否位于速度界限以内
            particles(j).v.x = min(particles(j).v.x, velBound(1,2));
            particles(j).v.x = max(particles(j).v.x, velBound(1,1));
            particles(j).v.y = min(particles(j).v.y, velBound(2,2));
            particles(j).v.y = max(particles(j).v.y, velBound(2,1));
            particles(j).v.z = min(particles(j).v.z, velBound(3,2));
            particles(j).v.z = max(particles(j).v.z, velBound(3,1));

            % 更新粒子位置
            particles(j).pos.x = particles(j).pos.x + particles(j).v.x;
            particles(j).pos.y = particles(j).pos.y + particles(j).v.y;
            particles(j).pos.z = particles(j).pos.z + particles(j).v.z;

            % 判断是否位于粒子位置界限以内
            particles(j).pos.x = max(particles(j).pos.x, posBound(1,1));
            particles(j).pos.x = min(particles(j).pos.x, posBound(1,2));
            particles(j).pos.y = max(particles(j).pos.y, posBound(2,1));
            particles(j).pos.y = min(particles(j).pos.y, posBound(2,2));
            particles(j).pos.z = max(particles(j).pos.z, posBound(3,1));
            particles(j).pos.z = min(particles(j).pos.z, posBound(3,2));

            % 适应度计算
            particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun);        

            % 更新全局最优粒子
            [particles,GlobalBest] = calBest(particles,GlobalBest);
        end


%         % 把每一代的最优粒子赋值给fitness_beat_iters
%         fitness_beat_iters(i) = GlobalBest.fitness;
% 
%         % 在命令行窗口显示每一代的信息
%         disp(['第' num2str(i) '代:' '最优适应度 = ' num2str(fitness_beat_iters(i)),',迭代运行时间:',num2str(toc)]);
% 
%         % 画图
%         [p1,p2] = irregular_threat(biology,air,h_ocean);
%         hold on
%         [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
%         legend([p1 p2 p3,p4,p5],{'水下生物威胁节点','大气威胁节点','起点','终点','UAV'})
%         colorbar
%         pause(0.001);
    end
% end
%%  保证输出可行路径
while GlobalBest.fitness > 1000
    for i = 1:N

        tic

        for j = 1:M  
            % 更新速度
            particles(j).v.x = w*particles(j).v.x ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.x-particles(j).pos.x) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.x-particles(j).pos.x);
            particles(j).v.y = w*particles(j).v.y ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.y-particles(j).pos.y) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.y-particles(j).pos.y);
            particles(j).v.z = w*particles(j).v.z ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.z-particles(j).pos.z) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.z-particles(j).pos.z);

            % 判断是否位于速度界限以内
            particles(j).v.x = min(particles(j).v.x, velBound(1,2));
            particles(j).v.x = max(particles(j).v.x, velBound(1,1));
            particles(j).v.y = min(particles(j).v.y, velBound(2,2));
            particles(j).v.y = max(particles(j).v.y, velBound(2,1));
            particles(j).v.z = min(particles(j).v.z, velBound(3,2));
            particles(j).v.z = max(particles(j).v.z, velBound(3,1));

            % 更新粒子位置
            particles(j).pos.x = particles(j).pos.x + particles(j).v.x;
            particles(j).pos.y = particles(j).pos.y + particles(j).v.y;
            particles(j).pos.z = particles(j).pos.z + particles(j).v.z;

            % 判断是否位于粒子位置界限以内
            particles(j).pos.x = max(particles(j).pos.x, posBound(1,1));
            particles(j).pos.x = min(particles(j).pos.x, posBound(1,2));
            particles(j).pos.y = max(particles(j).pos.y, posBound(2,1));
            particles(j).pos.y = min(particles(j).pos.y, posBound(2,2));
            particles(j).pos.z = max(particles(j).pos.z, posBound(3,1));
            particles(j).pos.z = min(particles(j).pos.z, posBound(3,2));

            % 适应度计算
            particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun);        

            % 更新全局最优粒子
            [particles,GlobalBest] = calBest(particles,GlobalBest);
        end


%         % 把每一代的最优粒子赋值给fitness_beat_iters
%         fitness_beat_iters(i) = GlobalBest.fitness;
% 
%         % 在命令行窗口显示每一代的信息
%         disp(['第' num2str(i) '代:' '最优适应度 = ' num2str(fitness_beat_iters(i)),',迭代运行时间:',num2str(toc)]);
% 
%         % 画图
%         [p1,p2] = irregular_threat(biology,air,h_ocean);
%         hold on
%         [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
%         legend([p1 p2 p3,p4,p5],{'水下生物威胁节点','大气威胁节点','起点','终点','UAV'})
%         colorbar
%         pause(0.001);
    end
end


%% 结果展示
% % 理论最小适应度：直线距离
% fitness_best = norm(startPos - goalPos);
% disp([ '理论最优适应度 = ' num2str(fitness_best)]);
% 
% % 绘制俯视角图
% figure
% [p1,p2] = irregular_threat(biology,air,h_ocean);
% hold on
% [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
% legend([p1 p2 p3,p4,p5],{'水下生物威胁节点','大气威胁节点','起点','终点','UAV'})
% colorbar
% view([0 0 1]);
% 
% % 画适应度迭代图
% figure
% plot(fitness_beat_iters,'LineWidth',2);
% xlabel('迭代次数');
% ylabel('最优适应度');
end