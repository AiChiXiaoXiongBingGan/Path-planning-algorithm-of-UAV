function [p3,p4] = plotFigure(startPos,goalPos,X,Y,Z,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun)


% 画起点和终点
p3 = scatter3(startPos(1), startPos(2), startPos(3),100,'bs','MarkerFaceColor','y');
hold on
p4 = scatter3(goalPos(1), goalPos(2), goalPos(3),100,'kp','MarkerFaceColor','y');

% 画山峰曲面
surf(X,Y,Z)      % 画曲面图
shading flat     % 各小曲面之间不要网格
hold on
plotcuboid([0,0,0],[100,100,h_ocean])  % 画海洋地形
hold on
mesh(x_radar,y_radar,z_radar,'FaceAlpha',0.5) % 画雷达模型
hold on
mesh(x_H_gun,y_H_gun,z_H_gun,'FaceAlpha',0.5) % 画高炮模型

% 画路径
% path = GlobalBest.path;
% pos = GlobalBest.pos;
% scatter3(pos.x, pos.y, pos.z, 'go');
% p5 = plot3(path(:,1), path(:,2),path(:,3), 'r','LineWidth',2);
hold off
legend('off')
grid on

