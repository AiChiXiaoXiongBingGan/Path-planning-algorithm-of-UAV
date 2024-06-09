function particles = initPop(M,pointNum,startPos,goalPos)
particles = struct;

% ��һ���ĸ����ʼ��
for i = 1:M
    % ��ʼ��
    particles(i).pos = [];
    particles(i).v = [];
    particles(i).fitness = [];
    particles(i).path = [];
    particles(i).Best.pos = [];
    particles(i).Best.fitness = inf;
    particles(i).Best.path = [];
    
    posBound(1,1) = min(startPos(1),goalPos(1));
    posBound(1,2) = max(startPos(1),goalPos(1));
    posBound(2,1) = min(startPos(2),goalPos(2));
    posBound(2,2) = max(startPos(2),goalPos(2));
    posBound(3,1) = min(startPos(3),goalPos(3));
    posBound(3,2) = max(startPos(3),goalPos(3));
    
    % ���Ӱ��վ��ȷֲ��������
    particles(i).pos.x = unifrnd(posBound(1,1),posBound(1,2),1,pointNum);
    particles(i).pos.y = unifrnd(posBound(2,1),posBound(2,2),1,pointNum);
    particles(i).pos.z = unifrnd(posBound(3,1),posBound(3,2),1,pointNum);
    
    % ��ʼ���ٶ�
    particles(i).v.x = zeros(1, pointNum);
    particles(i).v.y = zeros(1, pointNum);
    particles(i).v.z = zeros(1, pointNum);
end
end