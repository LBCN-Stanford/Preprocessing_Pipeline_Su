function phandle = plot_pval(pmatrix,t,color,ax,vis)
if nargin<5
    vis = 1;
end
phandle = zeros(1,size(pmatrix,2));
set(ax,'nextplot','add');
edge = round((size(pmatrix,1)-length(t))/2);
if edge <0
    edge = 0;
end
pmatrix=pmatrix(edge+1 : edge + length(t),:);
b = ax.YLim(1)/4;
b=abs(b)/size(pmatrix,2);
for i = 1:size(pmatrix,2)
    
    phandle(i) = plot(ax,t,pmatrix(:,i)-b*i,'color',color(i,:),'linewidth',1);
    set(phandle(i),'visible',vis)
end
set(ax,'nextplot','replace');