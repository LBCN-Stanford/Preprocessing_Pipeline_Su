function ehandles = show_heatmap(ax,ehandles,actMap,order,elecoor,show,ini)

%try 
    %G = handles.actMap(handles.curr_cond(app.sel_cond),:);

    %chan = handles.m(:,2);
    %map = map(handles.order);
%catch
%    [fn,~] = uigetfile;
%    G = load(fn);
%end
% if strcmp(char(handles.m(1,1)),'g') || strcmp(char(handles.m(1,1)),'s') 
%     alpha = 0.8;
% else
%     alpha = 0.15;
% end
% temp=tripatchDG(s,1);
% if size(s.vert,1)>2000000
%     model=reducepatch(temp,0.1);
% elseif size(s.vert,1)>1000000
%     model=reducepatch(temp,0.5);
% else
%     model.vertices=get(temp,'Vertices');
%     model.faces=get(temp,'Faces');
% end
% delete(temp);
% handles.model(handles.overlay).faces=model.faces;
% handles.model(handles.overlay).vertices=model.vertices;
%
% handles.overlay = 1;
% hi.tri=handles.model(handles.overlay).faces;
% hi.vert=handles.model(handles.overlay).vertices;
% %
% % handles.isrender=1;
% figure;gca;
set(ax,'nextplot','add');
%ax = gca;
%axes(handles.axes3);
% if get(handles.showR,'value') == 1
%     lh = tripatchDG(hi,1,'facecolor',[0.87 0.87 0.87],'clipping','on',...
%         'DiffuseStrength',  0.8, ...
%         'facealpha',alpha, 'edgecolor' , 'none','parent',ax,'FaceLighting','gouraud','FaceColor','interp');
%     set(ax,'nextplot','add');
%     set(lh,'facecolor',[0.87 0.87 0.87]);
% end
% if get(handles.showL,'value') == 1
%     handles.overlay = handles.overlay+1;
%     
%     hi.tri=handles.model(handles.overlay).faces;
%     hi.vert=handles.model(handles.overlay).vertices;
%     rh = tripatchDG(hi,1,...
%         'DiffuseStrength',  0.8, ...
%         'facealpha',alpha, 'edgecolor' , 'none','parent',ax,'FaceLighting','gouraud','FaceColor','interp');%,'lighting','gouraud','material','dull','shading','interp');
%     lighting gouraud; material dull;
%     hold on
%     
%     set(rh,'facecolor',[0.87 0.87 0.87]);
%     set(ax,'nextplot','add');
%     %ax.View=handles.elecoor(5,:);
%     %handles.light = camlight('headlight');
% end
% e = zeros(1,size(handles.group,1));
% if size(handles.elecoor,1) ~= handles.group(end)
%     handles.group(end) = size(handles.elecoor,1);
% end
%M = load('parula_map.mat');
colors = nan(length(actMap),3);
if ini ~= 1
    %colors = nan(length(order),3);


    G = actMap;%(order);
    G(isnan(G)) = 0;
    colors = squeeze(colormapping(G));
    %C=colormap(brewermap(length(order),'rdbu'));
    %colors = imagesc(G);%parula(length(actMap));
    %close gcf;
    %L = size(C,1);
    %Gs = round(interp1(linspace(min(G(:)),max(G(:)),L),1:L,G));
    %colors(~isnan(Gs),:) = C(~isnan(Gs),:);
    %colors(Gs == 1,:)=nan;
end

for i = 1:length(order)
    if show == 0 && ini ~= 1
        set(ehandles(i),'visible','off');
    elseif show ~= 0 && ini ~= 1
        try
            delete(ehandles(i));
        catch
        end
        ehandles(i) = plot3(ax,elecoor(i,1),elecoor(i,2),elecoor(i,3),...
            'o','markersize',8,'MarkerFaceColor',[51 45 130]/255,'MarkerEdgeColor','none');%all electrodes
        if ~isnan(colors(order(i),1))
            set(ehandles(i),'markerfacecolor',colors(order(i),:));%colored electrodes
        end
    end
end
set(ax,'nextplot','replace');