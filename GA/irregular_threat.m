function [p1,p2] = irregular_threat(biology,air,h_ocean)

% biology:ˮ�²�����������в��air:������в

p1=scatter3(biology(:,1),biology(:,2),ones(size(biology,1),1)*h_ocean/2,100,'kh','MarkerFaceColor','k');
hold on
p2=scatter3(air(:,1),air(:,2),ones(size(air,1),1)*h_ocean*2,100,'k^','MarkerFaceColor','k');


end

