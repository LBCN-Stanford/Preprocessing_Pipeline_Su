function plot_sig(ax,t,wave,trig,label)
plot(ax,t,wave,'linewidth',1,'color',[0.35 0.35 0.35]);
set(ax,'linewidth',1,'fontsize',12,'ticklength',[0.05 0.05],'ytick',[])%'color',[0.94 0.94 0.94]);
ax.XLim=([t(1) t(end)]);
ax.YLim=([-1 1]);
set(ax,'nextplot','add');
area(ax,t,trig,-1,'facealpha',0.3,'linestyle','none','facecolor',[0 0.45 0.74]);
txloc = round(0.5*length(t));%find(sign(diff(trig))==1);
for i = 1:length(label)
    %plot(app.onset_offset{i}(1):app.onset_offset{i}(2),zeros(length(anlg(app.onset_offset{i}(1):app.onset_offset{i}(2))),1), 'LineWidth', 50, 'Color', 'red')
    text(ax,t(txloc),0.5, label(i), 'FontSize', 20,'color',[0 0.45 0.74],'FontName','Optima','FontWeight','Bold');
end
set(ax,'nextplot','replace');
ax.XLabel.String=('Time (s)');
ax.YLabel.String='';