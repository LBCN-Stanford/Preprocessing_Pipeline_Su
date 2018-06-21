fprintf('%s\n','         =^._.^=         ')
fprintf('%s\n','------   Plotting  ------')
%%%%%%%%%%%%%%%%%%plot data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
chanp=1:cn;
%;round(80*size(signal_all{1}{1},1)/1000);
cc = linspecer(Nt);
if type ==1
    sparam = 15;
else
    sparam = 20;
end
if save_print
    resultdname = fillfile(pathname,'New figures');
        if ~exist(resultdname,'dir')
            mkdir(resultdname);
        end
end
for i=1:length(labels)
    labels{i}(ismember(labels{i},'_'))=' ';
end

[yl1, yl2] = get_ylim(signal_all,chanlabels(D{1}),0.9,1.4);

figure;
set(gcf,'Position',[500 600 800 600]);
set(gcf,'color',[1 1 1]);
for i=1:cn
    name=char(chanlabels(D{1},chanp(i)));
    if contains(lower(name), 'ekg') || contains(lower(name), 'edf') || contains(lower(name), 'ref')
        continue;
    end
    cla;
    allcond=true(Nt,1);
    temp_mean = nan(length(window),Nt);
    temp_std = nan(length(window),Nt);
    for j=1:Nt
        signal=signal_all{j}{i};
        signal = ndnanfilter(signal,'hamming',20,[],[],[],1);
        signal=signal(51:end-50,:);
        if isempty(signal) || size(signal,2) == 1
            %title(['Channel ',num2str(i),'  ',char(chanlabels(D{1},chanp(i))),' ','Ignoring bad cond.']);
            allcond(j)=0;
            continue;
        end
        nt=size(signal,2);
        vs=nanvar(signal);
        elim=vs>5*nanmedian(vs);
        temp_mean(:,j ) = nanmean(signal(:,~elim),2);
        temp_mean(:,j ) = smooth_sig(temp_mean(:,j ),sparam,4,1);
        temp_std(:,j ) = nanstd((signal(:,~elim)'),1)/sqrt(nt);
        temp_std(:,j ) = smooth_sig(temp_std(:,j ),sparam,4,1);
        before_samples=round(length(signal)/1000*(-(time_start*1000)));
        try
            plot(t,temp_mean(:,j),'color',cc(j,:),'linewidth',2);
            hold on
        catch
            allcond(j)=0;
            continue
        end
        
    end
    if isempty(temp_mean)
        continue;
    end
    
    %legend(labs(plot_cond(allcond)),'Location','NorthEastOutside');
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
    line([time_start time_end],[0 0],'LineWidth',2,'Color','k');
    %
    yl=get(gca,'ylim');
%     yl(2) = max(temp_mean(:))+max(temp_std(:));
%     yl(1) = mean(temp_mean(:))-max(temp_std(:));
switch bc_type
    case 'z'
     if yl(2) < 0.8 && yl(1) >-0.3 
         ylim([-0.2 1]);
         yl = [-0.2 1];
     elseif yl(2) < 2 && yl(1) >-0.5 
         ylim([-0.3 2.2]);
         yl = [-0.3 2.2];
     end
    case 'log'
             if yl(2) < 3 && yl(1) >-3 
         ylim([-2.5 3.5]);
         yl = [-2.5 3.5];
             end
end
%         yl2(i) = yl(2) * 1.2;
%     end
%     if yl1(i) > yl(1) 
%         yl1(i) = yl(1) * 0.8;
%     end
    %ylim([yl1(i) yl2(i)]);
    line([0 0],[yl(1) yl(2)],'color','k','linewidth',2);
    %line([0 0],[yl1(i) yl2(i)],'color','k','linewidth',2);
    xlim([t(1) t(end)])
    %xlim([time_start+0.15 t(end)-0.1]);
    %    ylim([-0.05 0.2]);
    %     try
    %         ylim([-0.2 yl2(2)]);
    %     catch
    %         continue
    %     end
    %      if yl(2)<2 && yl(1)>-0.3
    %          ylim([-0.2 1.5]);
    %
    %        % ylim([min(plot_min)-min(plot_min)*-.10 max(plot_max)+max(plot_max)*.10]);
    %     end
    legend(labels(plot_cond(allcond)),'Location','NorthEastOutside');
    hold off
    box off
    
    if save_print

        %print('-opengl','-r300','-dpng',strcat('New figures','/','S18_123','_',name,'_VTC'));
        print('-opengl','-r300','-dpng',fullfile(resultdname,strcat(name,'_',task)));
    else
        pause;
    end
end