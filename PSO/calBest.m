function [particles,GlobalBest] = calBest(particles,GlobalBest)
for i = 1:size(particles,2)
    % ���¸��������
    if particles(i).fitness < particles(i).Best.fitness
        particles(i).Best.pos = particles(i).pos;
        particles(i).Best.fitness = particles(i).fitness;
        particles(i).Best.path = particles(i).path;
    end
    
    % ����ȫ������
    if particles(i).Best.fitness < GlobalBest.fitness
        GlobalBest = particles(i).Best;
    end
end
