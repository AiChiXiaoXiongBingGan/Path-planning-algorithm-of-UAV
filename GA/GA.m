clc
clear
close all

%% 三维路径规划模型
startPos = [1, 1, 1];          %起始位置坐标
goalPos = [100, 100, 80];      %终止位置坐标

% 定义山峰地图
posBound = [0,100; 0,100; 0,100;];

% 定义海洋参数
h_ocean = 30;    %定义海洋深度
d_ocean = 1.5;   %海洋中航行能源消耗系数        
d_air = 1;       %大气中飞行能源消耗系数

% 地图长、宽、高范围
[X,Y,Z] = defMap(posBound);

% 定义威胁模型坐标
radar = [40 20 15];   %雷达威胁
H_gun = [70 70 15];   %高炮威胁坐标
biology = [60 20;80 30;10 60];    %水下不规则生物威胁坐标
air = [50 66];        %大气威胁坐标

%% 设置超参数
chromLength = 5;     % 染色体长度，代表路线的控制点数，未加首末两点
p_select = 0.5;      % 选择概率
p_crs = 0.8;         % 交叉概率
p_mut = 0.2;         % 变异概率
popNum = 50;         % 种群规模
iterMax = 100;       % 最大迭代数

%% 种群初始化
% 产生初始种群   
pop = initPop(popNum,chromLength,posBound);

% 计算种群适应度
pop = calFitness(startPos,goalPos,X,Y,Z,pop,d_ocean,d_air,h_ocean,radar,H_gun,air,biology);

% 更新种群最优
GlobalBest.fitness = inf; % 初始化每一代的最优粒子 inf为无穷大量∞
[pop,GlobalBest] = calBest(pop,GlobalBest); 

% 生成雷达模型
[x_radar,y_radar,z_radar] = sphere_threat(radar,h_ocean);

% 生成高炮模型
[x_H_gun,y_H_gun,z_H_gun] = sphere_threat(H_gun,h_ocean);

%最优适应度数组预分配内存
fitness_beat_iters = zeros(1,iterMax);

%% 主程序
for i = 1:iterMax  
    
    tic
    
    % 选择操作
    parentPop = select(pop, p_select);

    % 交叉操作
    childPop = crossover(parentPop,p_crs);
    
    % 变异操作
    childPop = mutation(childPop,p_mut,posBound);
    
    % 将父代和子代组合得到新的种群
    pop = [parentPop, childPop];
    
    % 计算种群适应度
    pop = calFitness(startPos, goalPos, X,Y,Z,pop,d_ocean,d_air,h_ocean,radar,H_gun,air,biology);

    % 更新种群最优
    [pop,GlobalBest] = calBest(pop,GlobalBest);
    
    % 把每一代的最优粒子赋值给fitness_beat_iters
    fitness_beat_iters(i) = GlobalBest.fitness;
    
    % 在命令行窗口显示每一代的信息
    disp(['第' num2str(i) '代:' '最优适应度 = ' num2str(fitness_beat_iters(i)),',迭代运行时间:',num2str(toc)]);
    
    % 画图
    [p1,p2] = irregular_threat(biology,air,h_ocean);
    hold on
    [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
    legend([p1 p2 p3 p4 p5],{'水下生物威胁节点','大气威胁节点','起点','终点','UAV'})
    colorbar
    pause(0.001);
end

% 理论最小适应度：直线距离
fitness_best = norm(startPos - goalPos);
disp([ '理论最优适应度 (直线距离) = ' num2str(fitness_best)]);

% 绘制俯视角图
figure
[p1,p2]= irregular_threat(biology,air,h_ocean);
hold on
[p3,p4,p5] =plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
legend([p1 p2 p3 p4 p5],{'水下生物威胁节点','大气威胁节点','起点','终点','UAV'})
colorbar
view([0 0 1]);

% 画适应度迭代图
figure
plot(fitness_beat_iters,'LineWidth',2);
xlabel('迭代次数');
ylabel('最优适应度');
