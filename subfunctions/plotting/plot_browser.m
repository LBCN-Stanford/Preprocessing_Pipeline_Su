function po = plot_browser(signal_all, sparam,labels,D,window,plot_cond, page, yl, bch,t,showlegend, cc)
if nargin < 11
    showlegend = 1;
end
Nt = length(plot_cond);
if nargin < 12
    cc = brewermap(Nt,'Set2');
    %cc = linspecer(Nt);
end
cn = nchannels(D{1});
chanp=1:cn;
edge = (round(size(signal_all{1}{1},1)-length(window))/2);
for i = page
     name=char(chanlabels(D{1},chanp(i)));
    if contains(lower(name), 'ekg') || contains(lower(name), 'edf') || contains(lower(name), 'ref')
        continue;
    end
    allcond=true(Nt,1);
    temp_mean = nan(length(window),Nt);
    temp_std = nan(length(window),Nt);
    for j=1:Nt
        signal=signal_all{j}{i};
        signal = ndnanfilter(signal,'hanning',round(sparam),[],[],[],1);
        signal=signal(edge+1:end-edge,:);
        if isempty(signal) || size(signal,2) == 1
            allcond(j)=0;
            continue;
        end
        nt=size(signal,2);
        vs=nanvar(signal);
        elim=vs>5*nanmedian(vs);
        temp_mean(:,j ) = nanmean(signal(:,~elim),2);
        pp=round(length(temp_mean)*10/500);
        temp_mean(:,j ) = smooth_sig(temp_mean(:,j ),pp,2,1);
        temp_std(:,j ) = nanstd((signal(:,~elim)'),1)/sqrt(1.1*nt);
        temp_std(:,j ) = smooth_sig(temp_std(:,j ),pp,2,1);
        try
            plot(t,temp_mean(:,j),'color',cc(j,:),'linewidth',3);
            hold on
        catch
            allcond(j)=0;
            continue
        end
        
    end
    if isempty(temp_mean)
        continue;
    end
    for j=1:Nt
        try
            shadedErrorBar(t,temp_mean(:,j),temp_std(:,j),'color',cc(j,:),1);
        catch
            continue
        end
    end
    if ismember(chanp(i),D{1}.badchannels) && ~ismember(chanp(i),bch{1})
        isgood = 'bad';
    elseif ismember(chanp(i),bch{1})
        isgood = 'Might be in the irritative zone';
    else
        isgood = 'Normal';
    end
    
    title(['Channel ',num2str(i),'  ',char(chanlabels(D{1},chanp(i))),'  (',isgood,')']);
    set(gca,'linewidth',2,'fontsize',16);
    line([t(1) t(end)],[0 0],'LineWidth',2,'Color','k');
    ylim([yl(1) yl(2)]);
    line([0 0],[yl(1) yl(2)],'color','k','linewidth',2);
    xlim([t(1) t(end)])
    xlabel('Time (s)');
    if showlegend
        le = legend(labels(plot_cond(allcond)),'Location','NorthEastoutside','box','off');
%     else
%         lb_emp = repmat({''},size(labels));
%         [le, ~] = legend(lb_emp(plot_cond(allcond)),'Location','NorthEast','box','off');
%         for ii = 1:length(hObjs)
%             hdl = hObjs(ii);
%             if strcmp(get(hdl, 'Type'), 'text')
%                 pos = get(hdl, 'Position');
%                 extent = get(hdl, 'Extent');    
%                 pos(1) = 1-extent(1)-extent(3); 
%                 set(hdl, 'Position', pos);
%             else    
%                 xData = get(hdl, 'XData');
%                 if length(xData) == 2 
%                     xDataNew = [1-xData(2), 1-xData(1)];
%                 else 
%                     xDataNew = 1-xData;
%                 end
%                 set(hdl, 'XData', xDataNew);
%             end
%         end
    end
    [po] = get(le,'position');
end
hold off
box off
end