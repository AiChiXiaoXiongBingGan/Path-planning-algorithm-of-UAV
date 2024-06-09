function [p3,p4] = plotFigure(startPos,goalPos,X,Y,Z,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun)


% �������յ�
p3 = scatter3(startPos(1), startPos(2), startPos(3),100,'bs','MarkerFaceColor','y');
hold on
p4 = scatter3(goalPos(1), goalPos(2), goalPos(3),100,'kp','MarkerFaceColor','y');

% ��ɽ������
surf(X,Y,Z)      % ������ͼ
shading flat     % ��С����֮�䲻Ҫ����
hold on
plotcuboid([0,0,0],[100,100,h_ocean])  % ���������
hold on
mesh(x_radar,y_radar,z_radar,'FaceAlpha',0.5) % ���״�ģ��
hold on
mesh(x_H_gun,y_H_gun,z_H_gun,'FaceAlpha',0.5) % ������ģ��

% ��·��
% path = GlobalBest.path;
% pos = GlobalBest.pos;
% scatter3(pos.x, pos.y, pos.z, 'go');
% p5 = plot3(path(:,1), path(:,2),path(:,3), 'r','LineWidth',2);
hold off
legend('off')
grid on

