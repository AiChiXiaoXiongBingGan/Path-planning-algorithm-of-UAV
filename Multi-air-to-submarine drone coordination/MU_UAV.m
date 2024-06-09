clc
clear
close all

%% 三维路径规划模型定义

startPos = [1, 1, 1];
goalPos = [100, 100, 80];
midPos = [20 40 60 80 90 60;40 80 70 90 10 10;60 70 90 80 70 30];
allPos = [startPos ; midPos' ; goalPos];
nSalesmen = 3;
N = size(allPos,1);

GlobalBest = struct;
for i = 1:size(allPos,1)
    for j=1:size(allPos,1)
        GlobalBest(i,j).pos = [];
        GlobalBest(i,j).fitness = inf;
        GlobalBest(i,j).path = [];
    end
end

h=waitbar(0,'please wait...'); %打开进度条，命名是为了方便关闭
%设置双缓存，为了防止在不断循环画动画的时候会产生闪烁的现象
set(h,'doublebuffer','on');
for i=1:size(allPos,1)
    for j=i:size(allPos,1)
        if i == j
            GlobalBest(i,j).fitness = 0;
        else
            GlobalBest(i,j) = PSO(allPos(i,:),allPos(j,:)); 
            dmat(i,j) = GlobalBest(i,j).fitness;
            dmat(j,i) = GlobalBest(i,j).fitness;
            GlobalBest(j,i) = GlobalBest(i,j);
        end
    end
    str=['迭代进度',num2str(round((i)/(size(allPos,1)),2)*100),'%...'];
    waitbar(round((i)/(size(allPos,1)),2),h,str);
    pause(0.05);
end
close(h);   %关闭进度条

pclr = ~get(0,'DefaultAxesColor');
clr = [1 0 0; 0 0 1; 0.67 0 1; 0 1 0; 1 0.5 0];
if nSalesmen > 5
    clr = hsv(nSalesmen);
end

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

% 生成雷达模型
[x_radar,y_radar,z_radar] = sphere_threat(radar,h_ocean);

% % 生成高炮模型
[x_H_gun,y_H_gun,z_H_gun] = sphere_threat(H_gun,h_ocean);

[ rng, opt_rte ]= MTSP( dmat,allPos );
% for s = 1:nSalesmen
%     rte = [1 opt_rte(rng(s,1):rng(s,2)) N];
%     i = size(rte,2);
%     for j=1:(i-1)
%     %下面用于三维画图，如果输入的坐标时三维的，那么就启动如下代码用以三维绘图
%     plot3(GlobalBest(rte(j),rte(j+1)).path(:,1),GlobalBest(rte(j),rte(j+1)).path(:,2),GlobalBest(rte(j),rte(j+1)).path(:,3),'.-','Color',clr(s,:),'LineWidth',2);
%     hold on
%     end
%     p3 = scatter3(allPos(rte,1), allPos(rte,2), allPos(rte,3),80,'go');
%     hold on
%     p4 = scatter3(allPos(rte,1), allPos(rte,2), allPos(rte,3),80,'go');
%     hold on
% end
for s = 1:nSalesmen
    rte = [1 opt_rte(rng(s,1):rng(s,2)) N];
    i = size(rte,2);
    UAV_beat_iters(s) = 0;
    for j=1:(i-1)
    %下面用于三维画图，如果输入的坐标时三维的，那么就启动如下代码用以三维绘图
    plot3(GlobalBest(rte(j),rte(j+1)).path(:,1),GlobalBest(rte(j),rte(j+1)).path(:,2),GlobalBest(rte(j),rte(j+1)).path(:,3),'.-','Color',clr(s,:),'LineWidth',2);
    hold on
    UAV_beat_iters(s) = UAV_beat_iters(s) + GlobalBest(rte(j),rte(j+1)).fitness;
    end
    % 在命令行窗口显示每一代的信息
    disp(['第' num2str(s) '架空潜无人机:' '最优适应度 = ' num2str(UAV_beat_iters(s)) ' 完成目标数量' num2str(i-2)]);
    scatter3(allPos(rte,1), allPos(rte,2), allPos(rte,3),80,'go');
    hold on
    scatter3(allPos(rte,1), allPos(rte,2), allPos(rte,3),80,'go');
    hold on
end

hold on
[p1,p2] = irregular_threat(biology,air,h_ocean);
hold on
[p3,p4] = plotFigure(startPos,goalPos,X,Y,Z,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
legend([p1 p2 p3,p4],{'水下生物威胁节点','大气威胁节点','起点','终点'})
colorbar