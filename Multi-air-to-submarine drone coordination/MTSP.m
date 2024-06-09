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

% Verify Inputs  验证输入是否可行，验证原理为城市个数 N 是否和 距离矩阵的 size相等
[N,~] = size(xy);
[nr,nc] = size(dmat);
if N ~= nr || N ~= nc
    error('Invalid XY or DMAT inputs!')
end
n = N-2;  %除去了起始点和结束点
 
% Sanity Checks    验证输入
nSalesmen = max(1,min(n,round(real(nSalesmen(1)))));  
%验证输入的旅行商个数是不是大于1，并且是整数
minTour = max(1,min(floor(n/nSalesmen),round(real(minTour(1)))));
%验证输入的minTour是不是大于1，并且是整数
popSize = max(8,8*ceil(popSize(1)/8));
%验证输入的个体数是否为8的整数（因为后面的分组8个为一组）
numIter = max(1,round(real(numIter(1))));
%验证输入的迭代次数是否大于1
showProg = logical(showProg(1));
%验证是否为1或0，下同
showResult = logical(showResult(1));
 
 
% Initializations for Route Break Point Selection
nBreaks = nSalesmen-1;    %设置中断点个数。
dof = n - minTour*nSalesmen;          % degrees of freedom
addto = ones(1,dof+1);
for k = 2:nBreaks
    addto = cumsum(addto);
end
cumProb = cumsum(addto)/sum(addto);
 
 
% Initialize the Populations
popRoute = zeros(popSize,n);          % population of routes，popRoute 为所有个体的路径基因型
popBreak = zeros(popSize,nBreaks);   % population of breaks
for k = 1:popSize
    popRoute(k,:) = randperm(n)+1;   %随机产生所有个体的路径基因型，下同。
    popBreak(k,:) = rand_breaks(minTour,n,nBreaks,cumProb);   %rand_breaks()为产生中断点的代码
end
 
 
%画图时，将每一个旅行商们走的路用不用颜色标出来。
pclr = ~get(0,'DefaultAxesColor');
clr = [1 0 0; 0 0 1; 0.67 0 1; 0 1 0; 1 0.5 0];
if nSalesmen > 5
    clr = hsv(nSalesmen);
end
 
% Run the GA
globalMin = Inf; %初始化全局最小值。设为无穷大
totalDist = zeros(1,popSize);  %初始化总距离，是一个行向量，每一个个体对一应一个总距离
distHistory = zeros(1,numIter);   %历史距离，用于比较最好的距离，每一次迭代，都产生一
%最好距离作为历史距离存起来。
tmpPopRoute = zeros(8,n);
%暂时变量。用于产生新个体的，（路径的基因型）
tmpPopBreak = zeros(8,nBreaks);
%同上，用于产生新的中断点的基因型
newPopRoute = zeros(popSize,n);
%新生代的路径基因型  
newPopBreak = zeros(popSize,nBreaks);
%新生代的断点基因型
% if showProg
%     pfig = figure('Name','MTSPOF_GA | Current Best Solution','Numbertitle','off');
% end
%画图：初始点
for iter = 1:numIter
    % Evaluate Members of the Population
    for p = 1:popSize
        d = 0;
        pRoute = popRoute(p,:);  
        %将相应的个体的路径基因型取出
        pBreak = popBreak(p,:);
        %将相应的个体的中断点基因型取出
        rng = [[1 pBreak+1];[pBreak n]]';
        %计算每个旅行商的距离之用
        %下面的迭代用于计算每个个体的对应的所有旅行商的总距离
        for s = 1:nSalesmen
            d = d + dmat(1,pRoute(rng(s,1))); % 加上从出发点到下一个城市的距离
            
            for k = rng(s,1):rng(s,2)-1   %加上路径中的距离
                d = d + dmat(pRoute(k),pRoute(k+1));
            end
            
            d = d + dmat(pRoute(rng(s,2)),N); % 加上从城市回到终点的距离
        end
        totalDist(p) = d;
    end
 
    % Find the Best Route in the Population
    [min_dist,index] = min(totalDist);
    distHistory(iter) = min_dist;
     
    if min_dist < globalMin
    %若本次迭代时的最佳距离小于历史全局最小值。
    %就把他画在图上，并记录一共画了几次。
        globalMin = min_dist;
        opt_rte = popRoute(index,:);
        opt_brk = popBreak(index,:);
        rng = [[1 opt_brk+1];[opt_brk n]]';
        if showProg
            % Plot the Best Route
%             figure(pfig);
            for s = 1:nSalesmen
                rte = [1 opt_rte(rng(s,1):rng(s,2)) N];
                %下面用于三维画图，如果输入的坐标时三维的，那么就启动如下代码用以三维绘图
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
 
    % 子代个体的产生过程
    % 产生一个随机序列，用于挑选随机的8个父代产生子代
    % 8个家伙来交配产生子代
    randomOrder = randperm(popSize);
    for p = 8:8:popSize
        rtes = popRoute(randomOrder(p-7:p),:);
        brks = popBreak(randomOrder(p-7:p),:);
        %随机挑选的8个父代
        dists = totalDist(randomOrder(p-7:p));
        [~,idx] = min(dists); 
        %从这8个父代中挑选出最佳父代，用于产生8个子代。
        bestOf8Route = rtes(idx,:);
        bestOf8Break = brks(idx,:);
        routeInsertionPoints = sort(ceil(n*rand(1,2)));
        %从中挑选出基因序列的2个位置
        %这两个位置用来从父代中产生新的基因新的
        I = routeInsertionPoints(1);
        J = routeInsertionPoints(2);
        for k = 1:8 % Generate New Solutions
            tmpPopRoute(k,:) = bestOf8Route;
            tmpPopBreak(k,:) = bestOf8Break;
            switch k
                case 2 % Flip
                    %将最佳父代的基因型从上面两个位置中间的片段反转，产生一个子代。
                    tmpPopRoute(k,I:J) = tmpPopRoute(k,J:-1:I);
                case 3 % Swap
                    %交换这两个片段的基因，产生新子代。
                    tmpPopRoute(k,[I J]) = tmpPopRoute(k,[J I]);
                case 4 % Slide
                    % 自己看吧，描述不出
                    tmpPopRoute(k,I:J) = tmpPopRoute(k,[I+1:J I]);
                    %上面都是调整路径基因型的
                    %下面用于调整中断点基因型
                case 5 % Modify Breaks
                    %随机产生，跟最佳父代没关系的一代。
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
%     %用于画出统计结果图
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
 
% 返回结果
% if nargout
%     varargout{1} = opt_rte;  %参数1 最佳个体的路径基因型
%     varargout{2} = opt_brk;   %参数2 最佳个体的中断点基因型
%     varargout{3} = min_dist;    %参数3 最佳个体的总距离
% end
 
%产生终端点代码（随机生成）
 
end  %结束总function