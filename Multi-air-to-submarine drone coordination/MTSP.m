function [ rng, opt_rte ]= MTSP( dmat,allPos )
% xy = 10*rand(10,2);
% xy = 10*rand([20,1,3]);
xy = [];
xy(:,:,1) = allPos(:,1);
xy(:,:,2) = allPos(:,2);
xy(:,:,3) = allPos(:,3);
N = size(xy,1);
% a = meshgrid(1:N);
% dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),N,N);
nSalesmen = 3;
minTour = 1;
popSize = 80;
numIter = 5e3;
showProg = 1;
showResult = 1;

% Verify Inputs  ��֤�����Ƿ���У���֤ԭ��Ϊ���и��� N �Ƿ�� �������� size���
[N,~] = size(xy);
[nr,nc] = size(dmat);
if N ~= nr || N ~= nc
    error('Invalid XY or DMAT inputs!')
end
n = N-2;  %��ȥ����ʼ��ͽ�����
 
% Sanity Checks    ��֤����
nSalesmen = max(1,min(n,round(real(nSalesmen(1)))));  
%��֤����������̸����ǲ��Ǵ���1������������
minTour = max(1,min(floor(n/nSalesmen),round(real(minTour(1)))));
%��֤�����minTour�ǲ��Ǵ���1������������
popSize = max(8,8*ceil(popSize(1)/8));
%��֤����ĸ������Ƿ�Ϊ8����������Ϊ����ķ���8��Ϊһ�飩
numIter = max(1,round(real(numIter(1))));
%��֤����ĵ��������Ƿ����1
showProg = logical(showProg(1));
%��֤�Ƿ�Ϊ1��0����ͬ
showResult = logical(showResult(1));
 
 
% Initializations for Route Break Point Selection
nBreaks = nSalesmen-1;    %�����жϵ������
dof = n - minTour*nSalesmen;          % degrees of freedom
addto = ones(1,dof+1);
for k = 2:nBreaks
    addto = cumsum(addto);
end
cumProb = cumsum(addto)/sum(addto);
 
 
% Initialize the Populations
popRoute = zeros(popSize,n);          % population of routes��popRoute Ϊ���и����·��������
popBreak = zeros(popSize,nBreaks);   % population of breaks
for k = 1:popSize
    popRoute(k,:) = randperm(n)+1;   %����������и����·�������ͣ���ͬ��
    popBreak(k,:) = rand_breaks(minTour,n,nBreaks,cumProb);   %rand_breaks()Ϊ�����жϵ�Ĵ���
end
 
 
%��ͼʱ����ÿһ�����������ߵ�·�ò�����ɫ�������
pclr = ~get(0,'DefaultAxesColor');
clr = [1 0 0; 0 0 1; 0.67 0 1; 0 1 0; 1 0.5 0];
if nSalesmen > 5
    clr = hsv(nSalesmen);
end
 
% Run the GA
globalMin = Inf; %��ʼ��ȫ����Сֵ����Ϊ�����
totalDist = zeros(1,popSize);  %��ʼ���ܾ��룬��һ����������ÿһ�������һӦһ���ܾ���
distHistory = zeros(1,numIter);   %��ʷ���룬���ڱȽ���õľ��룬ÿһ�ε�����������һ
%��þ�����Ϊ��ʷ�����������
tmpPopRoute = zeros(8,n);
%��ʱ���������ڲ����¸���ģ���·���Ļ����ͣ�
tmpPopBreak = zeros(8,nBreaks);
%ͬ�ϣ����ڲ����µ��жϵ�Ļ�����
newPopRoute = zeros(popSize,n);
%��������·��������  
newPopBreak = zeros(popSize,nBreaks);
%�������Ķϵ������
% if showProg
%     pfig = figure('Name','MTSPOF_GA | Current Best Solution','Numbertitle','off');
% end
%��ͼ����ʼ��
for iter = 1:numIter
    % Evaluate Members of the Population
    for p = 1:popSize
        d = 0;
        pRoute = popRoute(p,:);  
        %����Ӧ�ĸ����·��������ȡ��
        pBreak = popBreak(p,:);
        %����Ӧ�ĸ�����жϵ������ȡ��
        rng = [[1 pBreak+1];[pBreak n]]';
        %����ÿ�������̵ľ���֮��
        %����ĵ������ڼ���ÿ������Ķ�Ӧ�����������̵��ܾ���
        for s = 1:nSalesmen
            d = d + dmat(1,pRoute(rng(s,1))); % ���ϴӳ����㵽��һ�����еľ���
            
            for k = rng(s,1):rng(s,2)-1   %����·���еľ���
                d = d + dmat(pRoute(k),pRoute(k+1));
            end
            
            d = d + dmat(pRoute(rng(s,2)),N); % ���ϴӳ��лص��յ�ľ���
        end
        totalDist(p) = d;
    end
 
    % Find the Best Route in the Population
    [min_dist,index] = min(totalDist);
    distHistory(iter) = min_dist;
     
    if min_dist < globalMin
    %�����ε���ʱ����Ѿ���С����ʷȫ����Сֵ��
    %�Ͱ�������ͼ�ϣ�����¼һ�����˼��Ρ�
        globalMin = min_dist;
        opt_rte = popRoute(index,:);
        opt_brk = popBreak(index,:);
        rng = [[1 opt_brk+1];[opt_brk n]]';
        if showProg
            % Plot the Best Route
%             figure(pfig);
            for s = 1:nSalesmen
                rte = [1 opt_rte(rng(s,1):rng(s,2)) N];
                %����������ά��ͼ��������������ʱ��ά�ģ���ô���������´���������ά��ͼ
%                 if dims == 3, 
%                   plot3(xy(rte,1),xy(rte,2),xy(rte,3),'.-','Color',clr(s,:));
%                 else plot(xy(rte,1),xy(rte,2),'.-','Color',clr(s,:)); 
%                 end
%                 title(sprintf('Total Distance = %1.4f, Iteration = %d',min_dist,iter));
%                  hold on
            end
%             if dims == 3, 
%             plot3(xy(1,1),xy(1,2),xy(1,3),'ko',xy(N,1),xy(N,2),xy(N,3),'ko');
%             else plot(xy(1,1),xy(1,2),'ko',xy(N,1),xy(N,2),'ko');
%             end
%             hold off
        end
    end
 
    % �Ӵ�����Ĳ�������
    % ����һ��������У�������ѡ�����8�����������Ӵ�
    % 8���һ�����������Ӵ�
    randomOrder = randperm(popSize);
    for p = 8:8:popSize
        rtes = popRoute(randomOrder(p-7:p),:);
        brks = popBreak(randomOrder(p-7:p),:);
        %�����ѡ��8������
        dists = totalDist(randomOrder(p-7:p));
        [~,idx] = min(dists); 
        %����8����������ѡ����Ѹ��������ڲ���8���Ӵ���
        bestOf8Route = rtes(idx,:);
        bestOf8Break = brks(idx,:);
        routeInsertionPoints = sort(ceil(n*rand(1,2)));
        %������ѡ���������е�2��λ��
        %������λ�������Ӹ����в����µĻ����µ�
        I = routeInsertionPoints(1);
        J = routeInsertionPoints(2);
        for k = 1:8 % Generate New Solutions
            tmpPopRoute(k,:) = bestOf8Route;
            tmpPopBreak(k,:) = bestOf8Break;
            switch k
                case 2 % Flip
                    %����Ѹ����Ļ����ʹ���������λ���м��Ƭ�η�ת������һ���Ӵ���
                    tmpPopRoute(k,I:J) = tmpPopRoute(k,J:-1:I);
                case 3 % Swap
                    %����������Ƭ�εĻ��򣬲������Ӵ���
                    tmpPopRoute(k,[I J]) = tmpPopRoute(k,[J I]);
                case 4 % Slide
                    % �Լ����ɣ���������
                    tmpPopRoute(k,I:J) = tmpPopRoute(k,[I+1:J I]);
                    %���涼�ǵ���·�������͵�
                    %�������ڵ����жϵ������
                case 5 % Modify Breaks
                    %�������������Ѹ���û��ϵ��һ����
                    tmpPopBreak(k,:) = rand_breaks(minTour,n,nBreaks,cumProb);
                case 6 % Flip, Modify Breaks
                    tmpPopRoute(k,I:J) = tmpPopRoute(k,J:-1:I);
                    tmpPopBreak(k,:) = rand_breaks(minTour,n,nBreaks,cumProb);
                case 7 % Swap, Modify Breaks
                    tmpPopRoute(k,[I J]) = tmpPopRoute(k,[J I]);
                    tmpPopBreak(k,:) = rand_breaks(minTour,n,nBreaks,cumProb);
                case 8 % Slide, Modify Breaks
                    tmpPopRoute(k,I:J) = tmpPopRoute(k,[I+1:J I]);
                    tmpPopBreak(k,:) = rand_breaks(minTour,n,nBreaks,cumProb);
                otherwise % Do Nothing
            end
        end
        newPopRoute(p-7:p,:) = tmpPopRoute;
        newPopBreak(p-7:p,:) = tmpPopBreak;
    end
    popRoute = newPopRoute;
    popBreak = newPopBreak;
end
 
 
% if showResult
%     %���ڻ���ͳ�ƽ��ͼ
%     % Plots
%     figure('Name','MTSPOF_GA | Results','Numbertitle','off');
%     subplot(2,2,1);
%     if dims == 3, plot3(xy(:,1),xy(:,2),xy(:,3),'k.');
%     else plot(xy(:,1),xy(:,2),'k.'); 
%     end
%     title('City Locations');
%     subplot(2,2,2);
%     imagesc(dmat([1 opt_rte N],[1 opt_rte N]));
%     title('Distance Matrix');
%     subplot(2,2,3);
%     rng = [[1 opt_brk+1];[opt_brk n]]';
%     for s = 1:nSalesmen
%         rte = [1 opt_rte(rng(s,1):rng(s,2)) N];
%         if dims == 3, plot3(xy(rte,1),xy(rte,2),xy(rte,3),'.-','Color',clr(s,:));
%         else plot(xy(rte,1),xy(rte,2),'.-','Color',clr(s,:)); 
%         end
%         title(sprintf('Total Distance = %1.4f',min_dist));
%         hold on;
%     end
%     if dims == 3, plot3(xy(1,1),xy(1,2),xy(1,3),'ko',xy(N,1),xy(N,2),xy(N,3),'ko');
%     else plot(xy(1,1),xy(1,2),'ko',xy(N,1),xy(N,2),'ko'); 
%     end
%     subplot(2,2,4);
%     plot(distHistory,'b','LineWidth',2);
%     title('Best Solution History');
%     set(gca,'XLim',[0 numIter+1],'YLim',[0 1.1*max([1 distHistory])]);
% end
 
% ���ؽ��
% if nargout
%     varargout{1} = opt_rte;  %����1 ��Ѹ����·��������
%     varargout{2} = opt_brk;   %����2 ��Ѹ�����жϵ������
%     varargout{3} = min_dist;    %����3 ��Ѹ�����ܾ���
% end
 
%�����ն˵���루������ɣ�
 
end  %������function