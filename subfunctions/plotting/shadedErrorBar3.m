 function varargout=shadedErrorBar3(x,y,errBar,varargin)
% function H=shadedErrorBar(x,y,errBar,lineProps,transparent)
%
% Purpose 
% Makes a 2-d line plot with a pretty shaded error bar made
% using patch. Error bar color is chosen automatically.
%
% Inputs
% x - vector of x values [optional, can be left empty]
% y - vector of y values or a matrix of n observations by m cases
%     where m has length(x);
% errBar - if a vector we draw symmetric errorbars. If it has a size
%          of [2,length(x)] then we draw asymmetric error bars with
%          row 1 being the upper bar and row 2 being the lower bar
%          (with respect to y). ** alternatively ** errBar can be a
%          cellArray of two function handles. The first defines which
%          statistic the line should be and the second defines the
%          error bar.
% lineProps - [optional,'-k' by default] defines the properties of
%             the data line. e.g.:    
%             'or-', or {'-or','markerfacecolor',[1,0.2,0.2]}
% transparent - [optional, 0 by default] if ==1 the shaded error
%               bar is made transparent, which forces the renderer
%               to be openGl. However, if this is saved as .eps the
%               resulting file will contain a raster not a vector
%               image. 
%
% Outputs
% H - a structure of handles to the generated plot objects.     
%
%
% Examples
% y=randn(30,80); x=1:size(y,2);
% shadedErrorBar(x,mean(y,1),std(y),'g');
% shadedErrorBar(x,y,{@median,@std},{'r-o','markerfacecolor','r'});    
% shadedErrorBar([],y,{@median,@std},{'r-o','markerfacecolor','r'});    
%
% Overlay two transparent lines
% y=randn(30,80)*10; x=(1:size(y,2))-40;
% shadedErrorBar(x,y,{@mean,@std},'-r',1); 
% hold on
% y=ones(30,1)*x; y=y+0.06*y.^2+randn(size(y))*10;
% shadedErrorBar(x,y,{@mean,@std},'-b',1); 
% hold off
%
%
% Rob Campbell - November 2009


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Set default options
%ax = gca;
transparent = 1;
%col = [0 0.4470 0.7410];

%col = [0.8500    0.3250    0.0980];

%col = [0.9290    0.6940    0.1250];

%col = [64 180 187]/255;
%col = [203 77 12]/255;
linestyle = '-';
lw = 2;

for i =1:2:length(varargin)
    if strcmpi(varargin{i}, 'parent')
        ax = varargin{i+1};
    elseif strcmpi(varargin{i}, 'linestyle')
        linestyle = varargin{i+1};
    elseif strcmpi(varargin{i}, 'color')
        col = varargin{i+1};
    elseif strcmpi(varargin{i}, 'transparent')
        transparent = varargin{i+1};
    elseif strcmpi(varargin{i}, 'linewidth')
        lw = varargin{i+1};
    end
end

%Process y using function handles if needed to make the error bar
%dynamically
if iscell(errBar) 
    fun1=errBar{1};
    fun2=errBar{2};
    errBar=fun2(y);
    y=fun1(y);
else
    y=y(:)';
end

if isempty(x)
    x=1:length(y);
else
    x=x(:)';
end


%Make upper and lower error bars if only one was specified
if length(errBar)==length(errBar(:))
    errBar=repmat(errBar(:)',2,1);
else
    s=size(errBar);
    f=find(s==2);
    if isempty(f), error('errBar has the wrong size'), end
    if f==2, errBar=errBar'; end
end

if length(x) ~= length(errBar)
    error('length(x) must equal length(errBar)')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Work out the color of the shaded region and associated lines
% Using alpha requires the render to be openGL and so you can't
% save a vector image. On the other hand, you need alpha if you're
% overlaying lines. There we have the option of choosing alpha or a
% de-saturated solid colour for the patch surface .
H.mainLine=line(ax,'XData',x,'YData',y,'LineStyle',linestyle,'color',col,'LineWidth',lw);
col = get(H.mainLine,'color');
edgeColor=col+(1-col)*0.55;
patchSaturation=0.1; %How de-saturated or transparent to make patch
if transparent
    faceAlpha=patchSaturation;
    patchColor=col;
    %set(gca,'renderer','openGL')
else
    faceAlpha=1;
    patchColor=col+(1-col)*(1-patchSaturation);
    %set(gcf,'renderer','painters')
end

    
%Calculate the error bars
uE=y+errBar(1,:);
lE=y-errBar(2,:);

%Add the patch error bar
%holdStatus=ishold;
%if ~holdStatus, hold on,  end


%Make the patch
yP=[lE,fliplr(uE)];
xP=[x,fliplr(x)];

%remove nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];


H.patch=patch(xP,yP,1,'facecolor',patchColor,...
              'edgecolor','none',...
              'facealpha',faceAlpha,'parent',ax);


%Make pretty edges around the patch. 
%H.edge(1)=line(ax,'XData',x,'YData',lE,'LineStyle','-','color',edgeColor,'LineWidth',lw);
%H.edge(2)=line(ax,'XData',x,'YData',uE,'LineStyle','-','color',edgeColor,'LineWidth',lw);

%H.edge(1)=line(ax,'XData',x,'YData',lE,'LineStyle','none');
%H.edge(2)=line(ax,'XData',x,'YData',uE,'LineStyle','none');

H.edge(1)=line(ax,'XData',x,'YData',lE,'LineStyle','-','color',edgeColor,'LineWidth',0.25);
H.edge(2)=line(ax,'XData',x,'YData',uE,'LineStyle','-','color',edgeColor,'LineWidth',0.25);

ax.Children=flip(ax.Children);
%uistack(H.mainLine, 'top');
%Now replace the line (this avoids having to bugger about with z coordinates

if ~holdStatus, hold off, end

if nargout==1
    varargout{1}=H;
end
