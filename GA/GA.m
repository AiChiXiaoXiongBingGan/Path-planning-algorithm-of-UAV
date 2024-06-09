clc
clear
close all

%% ��ά·���滮ģ��
startPos = [1, 1, 1];          %��ʼλ������
goalPos = [100, 100, 80];      %��ֹλ������

% ����ɽ���ͼ
posBound = [0,100; 0,100; 0,100;];

% ���庣�����
h_ocean = 30;    %���庣�����
d_ocean = 1.5;   %�����к�����Դ����ϵ��        
d_air = 1;       %�����з�����Դ����ϵ��

% ��ͼ�������߷�Χ
[X,Y,Z] = defMap(posBound);

% ������вģ������
radar = [40 20 15];   %�״���в
H_gun = [70 70 15];   %������в����
biology = [60 20;80 30;10 60];    %ˮ�²�����������в����
air = [50 66];        %������в����

%% ���ó�����
chromLength = 5;     % Ⱦɫ�峤�ȣ�����·�ߵĿ��Ƶ�����δ����ĩ����
p_select = 0.5;      % ѡ�����
p_crs = 0.8;         % �������
p_mut = 0.2;         % �������
popNum = 50;         % ��Ⱥ��ģ
iterMax = 100;       % ��������

%% ��Ⱥ��ʼ��
% ������ʼ��Ⱥ   
pop = initPop(popNum,chromLength,posBound);

% ������Ⱥ��Ӧ��
pop = calFitness(startPos,goalPos,X,Y,Z,pop,d_ocean,d_air,h_ocean,radar,H_gun,air,biology);

% ������Ⱥ����
GlobalBest.fitness = inf; % ��ʼ��ÿһ������������ infΪ���������
[pop,GlobalBest] = calBest(pop,GlobalBest); 

% �����״�ģ��
[x_radar,y_radar,z_radar] = sphere_threat(radar,h_ocean);

% ���ɸ���ģ��
[x_H_gun,y_H_gun,z_H_gun] = sphere_threat(H_gun,h_ocean);

%������Ӧ������Ԥ�����ڴ�
fitness_beat_iters = zeros(1,iterMax);

%% ������
for i = 1:iterMax  
    
    tic
    
    % ѡ�����
    parentPop = select(pop, p_select);

    % �������
    childPop = crossover(parentPop,p_crs);
    
    % �������
    childPop = mutation(childPop,p_mut,posBound);
    
    % ���������Ӵ���ϵõ��µ���Ⱥ
    pop = [parentPop, childPop];
    
    % ������Ⱥ��Ӧ��
    pop = calFitness(startPos, goalPos, X,Y,Z,pop,d_ocean,d_air,h_ocean,radar,H_gun,air,biology);

    % ������Ⱥ����
    [pop,GlobalBest] = calBest(pop,GlobalBest);
    
    % ��ÿһ�����������Ӹ�ֵ��fitness_beat_iters
    fitness_beat_iters(i) = GlobalBest.fitness;
    
    % �������д�����ʾÿһ������Ϣ
    disp(['��' num2str(i) '��:' '������Ӧ�� = ' num2str(fitness_beat_iters(i)),',��������ʱ��:',num2str(toc)]);
    
    % ��ͼ
    [p1,p2] = irregular_threat(biology,air,h_ocean);
    hold on
    [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
    legend([p1 p2 p3 p4 p5],{'ˮ��������в�ڵ�','������в�ڵ�','���','�յ�','UAV'})
    colorbar
    pause(0.001);
end

% ������С��Ӧ�ȣ�ֱ�߾���
fitness_best = norm(startPos - goalPos);
disp([ '����������Ӧ�� (ֱ�߾���) = ' num2str(fitness_best)]);

% ���Ƹ��ӽ�ͼ
figure
[p1,p2]= irregular_threat(biology,air,h_ocean);
hold on
[p3,p4,p5] =plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
legend([p1 p2 p3 p4 p5],{'ˮ��������в�ڵ�','������в�ڵ�','���','�յ�','UAV'})
colorbar
view([0 0 1]);

% ����Ӧ�ȵ���ͼ
figure
plot(fitness_beat_iters,'LineWidth',2);
xlabel('��������');
ylabel('������Ӧ��');
