function [p1,p2] = irregular_threat(biology,air,h_ocean)

% biology:水下不规则生物威胁；air:空气威胁

p1=scatter3(biology(:,1),biology(:,2),ones(size(biology,1),1)*h_ocean/2,100,'kh','MarkerFaceColor','k');
hold on
p2=scatter3(air(:,1),air(:,2),ones(size(air,1),1)*h_ocean*2,100,'k^','MarkerFaceColor','k');


end

