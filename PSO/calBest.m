function [particles,GlobalBest] = calBest(particles,GlobalBest)
for i = 1:size(particles,2)
    % 更新个体的最优
    if particles(i).fitness < particles(i).Best.fitness
        particles(i).Best.pos = particles(i).pos;
        particles(i).Best.fitness = particles(i).fitness;
        particles(i).Best.path = particles(i).path;
    end
    
    % 更新全局最优
    if particles(i).Best.fitness < GlobalBest.fitness
        GlobalBest = particles(i).Best;
    end
end
