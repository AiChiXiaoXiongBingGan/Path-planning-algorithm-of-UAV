function particles = initPop(M,pointNum,posBound)
particles = struct;

% 第一代的个体初始化
for i = 1:M
    % 初始化
    particles(i).pos = [];
    particles(i).v = [];
    particles(i).fitness = [];
    particles(i).path = [];
    particles(i).Best.pos = [];
    particles(i).Best.fitness = inf;
    particles(i).Best.path = [];
    
    % 粒子按照均匀分布随机生成
    particles(i).pos.x = unifrnd(posBound(1,1),posBound(1,2),1,pointNum);
    particles(i).pos.y = unifrnd(posBound(2,1),posBound(2,2),1,pointNum);
    particles(i).pos.z = unifrnd(posBound(3,1),posBound(3,2),1,pointNum);
    
    % 初始化速度
    particles(i).v.x = zeros(1, pointNum);
    particles(i).v.y = zeros(1, pointNum);
    particles(i).v.z = zeros(1, pointNum);
end
end