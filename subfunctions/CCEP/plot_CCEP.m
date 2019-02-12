
t = 0:size(zCCEP{1}{1},1);
t(1)=[];
t=t/1000;
t=t-0.2;
chan=chanLabel;
n=1;
[b,a]=butter(2,[1 400]/(1000/2));
elim=false(size(zCCEP{1}{1},2),1);
for i = plotchan
    for j = 1:size(group,1)
        sig = zCCEP{i}{j};
        nv=nanvar(sig(:,:));
        nv2=nanvar(filtfilt(b,a,sig(300:end,:)));
        
        elim= (nv>=10*median(nv));
        %elim= elim + (nv2<=0.1*median(nv2));
        
        elim=logical(elim+(nanmax(abs(sig))>= 100));
        try
        signals{i}(:,j)=nanmean(zCCEP{i}{j}(:,~elim)');
        catch
            signals{i}(:,j) = nan;
            continue;
        end
%         if size(signals{i}(:,j),2) <=4
%             signals{i}(:,j)=nan;
%         end
        if max(abs(signals{i}(:,j)))~=max((signals{i}(:,j)))
            signals{i}(:,j) = -signals{i}(:,j);
        end
        maxvalue(n) = max(signals{i}(:,j));
        minvalue(n) = min(signals{i}(:,j));
        n = n+1;
    end
     maxvalue(n) = nanmax(signals{i}(:));
    minvalue(n) = nanmin(signals{i}(:));
end
yl(1)=min(minvalue);
yl(2)=max(maxvalue);
if yl(2)<5
    yl(2)=5;
end
    
figure;
if size(group,1) <= 2
    wid = 0.2;
elseif size(group,1) <= 4
    wid = 0.4;
else
    wid = 0.9;
end


if length(plotchan)<=2
    hei = 0.2;
    ini = 0.8;
elseif length(plotchan)<=4
    hei = 0.4;
    ini = 0.5;
else
    hei = 0.95;
    ini = 0.1;
end

pos = [0.1 ini wid hei];

P=tight_subplot(length(plotchan),size(group,1),[.02 .02],[.02 .02],[.08 .05]);
        set(gcf,'Unit','normalized','Position',pos,'color',[1 1 1]);
n=1;
for i =plotchan

    %figure;
    
    %title(strcat('chan',num2str(i)));
    %      P=tight_subplot(length(group),length(plotch),[.02 .02],[.02 .02],[.1 .05]);
    %         set(gcf,'Unit','normalized','Positclearion',[0.2 0.2 0.91 0.8],'color',[1 1 1]);
    for j = 1:size(group,1)
        %      for j = 1
        axes(P(n));
        if strcmpi(cond{j}(5:end),chan{i})
            n = n+1;
            continue;
        end
        try
            plot(t,signals{i}(:,j),'linewidth',2)
        catch
        end
        if n <=length(cond)
            title(cond{j});
            hold on
        end
         if j == 1
            ylabel(chan{i});
            hold on
        end
        
        
        hold on
        line([-0.1 0.8],[0 0],'LineWidth',1,'Color','k');
        line([0 0],[-50 100],'color','k','linewidth',1);
        xlim([-0.1 0.8]);
        try
            ylim([-abs(yl(1))*1.05 yl(2)*1.05]);
        catch
        end
        set(gca,'ticklength',[0.001 0.001],'fontsize',10)
        hold off
        box off
        
        n=n+1;
    end
    xlabel('Time (s)');
end