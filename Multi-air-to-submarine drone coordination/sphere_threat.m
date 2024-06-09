function [x_theat,y_theat,z_theat] = sphere_threat(threat_mod,h_ocean)

r=linspace(0,threat_mod(3),20); 
t=0:pi/10:2*pi; 
[R1, T]=meshgrid(r,t); 
xj=R1.*cos(T); 
yj=R1.*sin(T); 
zj=sqrt(threat_mod(3).^2-xj.*xj - yj.*yj); 
zj=abs(zj);
x_theat=xj+threat_mod(1);
y_theat=yj+threat_mod(2);
z_theat=zj+h_ocean;

end

