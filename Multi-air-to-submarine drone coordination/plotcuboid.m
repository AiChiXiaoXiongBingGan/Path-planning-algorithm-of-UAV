function plotcuboid(originPoint,cuboidSize)
%% �������ܣ� ���Ƴ�����
% ���룺
%       originPoint���������ԭ��,����������[0��0��0];
%       cuboidSize��������ĳ����,����������[10��20��30];
% �����������ͼ��

%% ����ԭ��ͳߴ磬���㳤�����8���Ķ���
vertexIndex=[0 0 0;0 0 1;0 1 0;0 1 1;1 0 0;1 0 1;1 1 0;1 1 1];
vertex=originPoint+vertexIndex.*cuboidSize;

%% ����6��ƽ��ֱ��Ӧ�Ķ���
facet=[1 2 4 3;1 2 6 5;1 3 7 5;2 4 8 6;3 4 8 7;5 6 8 7];

%% ���Ʋ�չʾͼ��
% patch ��ͼ����л��ơ�
% view(3) ��ͼ��ŵ���ά�ռ���չʾ��
% ����������ñ����ȵ�
patch('Vertices',vertex,'Faces',facet,'FaceColor',[0.3010 0.7450 0.9330],'FaceAlpha',0.5);
view(3);
% fig=gcf;
% fig.Color=[1 1 1];
% fig.Name='cuboid';
% fig.NumberTitle='off';
end
