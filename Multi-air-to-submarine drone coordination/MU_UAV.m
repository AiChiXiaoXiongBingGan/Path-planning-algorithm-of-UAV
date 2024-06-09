clc
clear
close all

%% ��ά·���滮ģ�Ͷ���

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

h=waitbar(0,'please wait...'); %�򿪽�������������Ϊ�˷���ر�
%����˫���棬Ϊ�˷�ֹ�ڲ���ѭ����������ʱ��������˸������
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
    str=['��������',num2str(round((i)/(size(allPos,1)),2)*100),'%...'];
    waitbar(round((i)/(size(allPos,1)),2),h,str);
    pause(0.05);
end
close(h);   %�رս�����

pclr = ~get(0,'DefaultAxesColor');
clr = [1 0 0; 0 0 1; 0.67 0 1; 0 1 0; 1 0.5 0];
if nSalesmen > 5
    clr = hsv(nSalesmen);
end

% �������ɽ���ͼ
mapRange = [100,100,100];              % ��ͼ�������߷�Χ
[X,Y,Z] = defMap(mapRange);

% ���庣�����
h_ocean = 30;   %���庣�����
d_ocean = 1;    %�����к�����Դ����ϵ��        
d_air = 1;      %�����з�����Դ����ϵ��

% ������вģ������
radar = [40 20 10];   %�״���в
H_gun = [70 70 10];   %������в����
biology = [60 20;80 30;10 60];    %ˮ�²�����������в����
air = [50 66];        %������в����

% �����״�ģ��
[x_radar,y_radar,z_radar] = sphere_threat(radar,h_ocean);

% % ���ɸ���ģ��
[x_H_gun,y_H_gun,z_H_gun] = sphere_threat(H_gun,h_ocean);

[ rng, opt_rte ]= MTSP( dmat,allPos );
% for s = 1:nSalesmen
%     rte = [1 opt_rte(rng(s,1):rng(s,2)) N];
%     i = size(rte,2);
%     for j=1:(i-1)
%     %����������ά��ͼ��������������ʱ��ά�ģ���ô���������´���������ά��ͼ
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
    %����������ά��ͼ��������������ʱ��ά�ģ���ô���������´���������ά��ͼ
    plot3(GlobalBest(rte(j),rte(j+1)).path(:,1),GlobalBest(rte(j),rte(j+1)).path(:,2),GlobalBest(rte(j),rte(j+1)).path(:,3),'.-','Color',clr(s,:),'LineWidth',2);
    hold on
    UAV_beat_iters(s) = UAV_beat_iters(s) + GlobalBest(rte(j),rte(j+1)).fitness;
    end
    % �������д�����ʾÿһ������Ϣ
    disp(['��' num2str(s) '�ܿ�Ǳ���˻�:' '������Ӧ�� = ' num2str(UAV_beat_iters(s)) ' ���Ŀ������' num2str(i-2)]);
    scatter3(allPos(rte,1), allPos(rte,2), allPos(rte,3),80,'go');
    hold on
    scatter3(allPos(rte,1), allPos(rte,2), allPos(rte,3),80,'go');
    hold on
end

hold on
[p1,p2] = irregular_threat(biology,air,h_ocean);
hold on
[p3,p4] = plotFigure(startPos,goalPos,X,Y,Z,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
legend([p1 p2 p3,p4],{'ˮ��������в�ڵ�','������в�ڵ�','���','�յ�'})
colorbar