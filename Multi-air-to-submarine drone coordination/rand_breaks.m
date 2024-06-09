function breaks = rand_breaks(minTour,n,nBreaks,cumProb)
    if minTour == 1 % No Constraints on Breaks
        tmpBreaks = randperm(n-1);
        breaks = sort(tmpBreaks(1:nBreaks));
    else % Force Breaks to be at Least the Minimum Tour Length
        num_adjust = find(rand < cumProb,1)-1;
        spaces = ceil(nBreaks*rand(1,num_adjust));
        adjust = zeros(1,nBreaks);
        for kk = 1:nBreaks
            adjust(kk) = sum(spaces == kk);
        end
        breaks = minTour*(1:nBreaks) + cumsum(adjust);
    end
end
