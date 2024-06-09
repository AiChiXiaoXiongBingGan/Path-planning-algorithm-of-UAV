function GlobalBest = PSO(startPos,goalPos) 

% startPos = [1, 1, 1];
% goalPos = [20, 40, 60];
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

%% ��ʼ��������
N = 100;           % ��������
M = 10;            % ��������
pointNum = 3;      % ÿһ�����Ӱ�������λ�õ�
w = 1.2;           % ����Ȩ��
c1 = 2;            % ����Ȩ��
c2 = 2;            % ���Ȩ��

% ����λ�ý���
posBound = [[0,0,0]',mapRange'];

% �����ٶȽ���
alpha = 0.1;
velBound(:,2) = alpha*(posBound(:,2) - posBound(:,1));
velBound(:,1) = -velBound(:,2);

%% ��Ⱥ��ʼ��
% ��ʼ��ÿһ������������
GlobalBest.fitness = inf;
% while GlobalBest.fitness > 1000  % ��֤����Ⱥ���к��п���·��
    % ������ʼ����
    particles = initPop(M,pointNum,startPos,goalPos);

    % ����������Ӧ��
    particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun);   

    % ����ȫ����������
    [particles,GlobalBest] = calBest(particles,GlobalBest);
% end

% % �����״�ģ��
% [x_radar,y_radar,z_radar] = sphere_threat(radar,h_ocean);
% 
% %  ���ɸ���ģ��
% [x_H_gun,y_H_gun,z_H_gun] = sphere_threat(H_gun,h_ocean);

% % ��ʼ��ÿһ����������Ӧ�ȣ����ڻ���Ӧ�ȵ���ͼ
% fitness_beat_iters = zeros(N,1);

%% ������
% while GlobalBest.fitness > 1000
    for i = 1:N

        tic

        for j = 1:M  
            % �����ٶ�
            particles(j).v.x = w*particles(j).v.x ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.x-particles(j).pos.x) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.x-particles(j).pos.x);
            particles(j).v.y = w*particles(j).v.y ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.y-particles(j).pos.y) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.y-particles(j).pos.y);
            particles(j).v.z = w*particles(j).v.z ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.z-particles(j).pos.z) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.z-particles(j).pos.z);

            % �ж��Ƿ�λ���ٶȽ�������
            particles(j).v.x = min(particles(j).v.x, velBound(1,2));
            particles(j).v.x = max(particles(j).v.x, velBound(1,1));
            particles(j).v.y = min(particles(j).v.y, velBound(2,2));
            particles(j).v.y = max(particles(j).v.y, velBound(2,1));
            particles(j).v.z = min(particles(j).v.z, velBound(3,2));
            particles(j).v.z = max(particles(j).v.z, velBound(3,1));

            % ��������λ��
            particles(j).pos.x = particles(j).pos.x + particles(j).v.x;
            particles(j).pos.y = particles(j).pos.y + particles(j).v.y;
            particles(j).pos.z = particles(j).pos.z + particles(j).v.z;

            % �ж��Ƿ�λ������λ�ý�������
            particles(j).pos.x = max(particles(j).pos.x, posBound(1,1));
            particles(j).pos.x = min(particles(j).pos.x, posBound(1,2));
            particles(j).pos.y = max(particles(j).pos.y, posBound(2,1));
            particles(j).pos.y = min(particles(j).pos.y, posBound(2,2));
            particles(j).pos.z = max(particles(j).pos.z, posBound(3,1));
            particles(j).pos.z = min(particles(j).pos.z, posBound(3,2));

            % ��Ӧ�ȼ���
            particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun);        

            % ����ȫ����������
            [particles,GlobalBest] = calBest(particles,GlobalBest);
        end


%         % ��ÿһ�����������Ӹ�ֵ��fitness_beat_iters
%         fitness_beat_iters(i) = GlobalBest.fitness;
% 
%         % �������д�����ʾÿһ������Ϣ
%         disp(['��' num2str(i) '��:' '������Ӧ�� = ' num2str(fitness_beat_iters(i)),',��������ʱ��:',num2str(toc)]);
% 
%         % ��ͼ
%         [p1,p2] = irregular_threat(biology,air,h_ocean);
%         hold on
%         [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
%         legend([p1 p2 p3,p4,p5],{'ˮ��������в�ڵ�','������в�ڵ�','���','�յ�','UAV'})
%         colorbar
%         pause(0.001);
    end
% end
%%  ��֤�������·��
while GlobalBest.fitness > 1000
    for i = 1:N

        tic

        for j = 1:M  
            % �����ٶ�
            particles(j).v.x = w*particles(j).v.x ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.x-particles(j).pos.x) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.x-particles(j).pos.x);
            particles(j).v.y = w*particles(j).v.y ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.y-particles(j).pos.y) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.y-particles(j).pos.y);
            particles(j).v.z = w*particles(j).v.z ...
                + c1*rand([1,pointNum]).*(particles(j).Best.pos.z-particles(j).pos.z) ...
                + c2*rand([1,pointNum]).*(GlobalBest.pos.z-particles(j).pos.z);

            % �ж��Ƿ�λ���ٶȽ�������
            particles(j).v.x = min(particles(j).v.x, velBound(1,2));
            particles(j).v.x = max(particles(j).v.x, velBound(1,1));
            particles(j).v.y = min(particles(j).v.y, velBound(2,2));
            particles(j).v.y = max(particles(j).v.y, velBound(2,1));
            particles(j).v.z = min(particles(j).v.z, velBound(3,2));
            particles(j).v.z = max(particles(j).v.z, velBound(3,1));

            % ��������λ��
            particles(j).pos.x = particles(j).pos.x + particles(j).v.x;
            particles(j).pos.y = particles(j).pos.y + particles(j).v.y;
            particles(j).pos.z = particles(j).pos.z + particles(j).v.z;

            % �ж��Ƿ�λ������λ�ý�������
            particles(j).pos.x = max(particles(j).pos.x, posBound(1,1));
            particles(j).pos.x = min(particles(j).pos.x, posBound(1,2));
            particles(j).pos.y = max(particles(j).pos.y, posBound(2,1));
            particles(j).pos.y = min(particles(j).pos.y, posBound(2,2));
            particles(j).pos.z = max(particles(j).pos.z, posBound(3,1));
            particles(j).pos.z = min(particles(j).pos.z, posBound(3,2));

            % ��Ӧ�ȼ���
            particles = calFitness(startPos,goalPos,X,Y,Z,particles,d_ocean,d_air,h_ocean,radar,H_gun);        

            % ����ȫ����������
            [particles,GlobalBest] = calBest(particles,GlobalBest);
        end


%         % ��ÿһ�����������Ӹ�ֵ��fitness_beat_iters
%         fitness_beat_iters(i) = GlobalBest.fitness;
% 
%         % �������д�����ʾÿһ������Ϣ
%         disp(['��' num2str(i) '��:' '������Ӧ�� = ' num2str(fitness_beat_iters(i)),',��������ʱ��:',num2str(toc)]);
% 
%         % ��ͼ
%         [p1,p2] = irregular_threat(biology,air,h_ocean);
%         hold on
%         [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
%         legend([p1 p2 p3,p4,p5],{'ˮ��������в�ڵ�','������в�ڵ�','���','�յ�','UAV'})
%         colorbar
%         pause(0.001);
    end
end


%% ���չʾ
% % ������С��Ӧ�ȣ�ֱ�߾���
% fitness_best = norm(startPos - goalPos);
% disp([ '����������Ӧ�� = ' num2str(fitness_best)]);
% 
% % ���Ƹ��ӽ�ͼ
% figure
% [p1,p2] = irregular_threat(biology,air,h_ocean);
% hold on
% [p3,p4,p5] = plotFigure(startPos,goalPos,X,Y,Z,GlobalBest,h_ocean,x_radar,y_radar,z_radar,x_H_gun,y_H_gun,z_H_gun);
% legend([p1 p2 p3,p4,p5],{'ˮ��������в�ڵ�','������в�ڵ�','���','�յ�','UAV'})
% colorbar
% view([0 0 1]);
% 
% % ����Ӧ�ȵ���ͼ
% figure
% plot(fitness_beat_iters,'LineWidth',2);
% xlabel('��������');
% ylabel('������Ӧ��');
end