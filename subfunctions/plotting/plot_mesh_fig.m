function handles = plot_mesh_fig(handles)


alpha = handles.slider1.Value;
alpha =1;

handles.overlay = 1;
hi.tri=handles.model(handles.overlay).faces;
hi.vert=handles.model(handles.overlay).vertices;

figure;gca;
ax = gca;

if handles.showR.Value == 1
    lh = tripatchDG(hi,1,'facecolor',[0.87 0.87 0.87],'clipping','on',...
        'DiffuseStrength',  0.8, ...
        'facealpha',alpha, 'edgecolor' , 'none','parent',ax,'FaceLighting','gouraud','FaceColor','interp');
    set(ax,'nextplot','add');
    set(lh,'facecolor',[0.87 0.87 0.87]);
    
end
if handles.showL.Value == 1
    handles.overlay = handles.overlay+1;
    
    hi.tri=handles.model(handles.overlay).faces;
    hi.vert=handles.model(handles.overlay).vertices;
    rh = tripatchDG(hi,1,...
        'DiffuseStrength',  0.8, ...
        'facealpha',alpha, 'edgecolor' , 'none','parent',ax,'FaceLighting','gouraud','FaceColor','interp');
    lighting gouraud; material dull;
    hold on
    
    set(rh,'facecolor',[0.87 0.87 0.87]);
    set(ax,'nextplot','add');
    
end
e = zeros(1,size(handles.group,1));
if size(handles.elecoor,1) ~= handles.group(end)
    handles.group(end) = size(handles.elecoor,1);
end

if handles.showMap.Value == 0
    
    
    for j=1:size(handles.group,1)
        
        type = char(handles.m(handles.group(j,1),1));
        if strcmpi(type(2),'s') || strcmpi(type(2),'g')
            %handles.elecoor=handles.elecoor.*0.99;
            [side,top,~]=electrode3d(handles.elecoor(handles.group(j,1):handles.group(j,2),1),...
                handles.elecoor(handles.group(j,1):handles.group(j,2),2),...
                handles.elecoor(handles.group(j,1):handles.group(j,2),3),...
                handles.elecRgb(handles.group(j,1),:),2.5,0,5,0,handles.head_center,ax);
            
            ele(j).side=patch('faces',side.faces,'vertices',...
                side.vertices,'edgecolor','none','facecolor',(handles.elecRgb(handles.group(j,1),:)),'facelighting',...
                'gouraud','parent',ax);
            
            e(j)=patch('faces',top.faces,'vertices',...
                top.vertices,'edgecolor','none','facecolor',handles.elecRgb(handles.group(j,1),:),'facelighting',...
                'gouraud',...
                'DiffuseStrength',  0.5, ...
                'SpecularStrength', 0.1, ...
                'SpecularColorReflectance', 0.2,'parent',ax);
        elseif strcmpi(type(2),'d')
            
            e(j) = plot3(handles.elecoor(handles.group(j,1):handles.group(j,2),1),handles.elecoor(handles.group(j,1):handles.group(j,2),2),...
                handles.elecoor(handles.group(j,1):handles.group(j,2),3),...
                '.','markersize',15,'color',handles.elecRgb(handles.group(j,1),:),'parent',ax);%'.','markersize',15,'color','k','parent',ax); %
            
        end
        set(ax,'nextplot','add');
    end
    try
        legend(ax,e, handles.groupNames,'Orientation','horizontal','location',...
            'south','AutoUpdate','off','NumColumns',6, 'fontsize',12,'color','none');
    catch
        legend(ax,e, handles.groupNames,'Orientation','horizontal','location',...
            'south','AutoUpdate','off', 'fontsize',12,'color','none');
    end
else
    alllabels = handles.labels(handles.plot_cond(handles.sel_cond));
    current = strcmpi(alllabels,handles.ConditionDropDown.Value);
    colors = nan(length(handles.actMap(current,:)),3);
    
        %colors = nan(length(order),3);
        
        
        G = handles.actMap(current,:);%(order);
        G(isnan(G)) = 0;
        colors = squeeze(colormapping(G));
        %C=colormap(brewermap(length(order),'rdbu'));
        %colors = imagesc(G);%parula(length(actMap));
        %close gcf;
        %L = size(C,1);
        %Gs = round(interp1(linspace(min(G(:)),max(G(:)),L),1:L,G));
        %colors(~isnan(Gs),:) = C(~isnan(Gs),:);
        %colors(Gs == 1,:)=nan
    
    for i = 1:length(handles.order)

                ehandles(i) = plot3(ax,handles.elecoor(i,1),handles.elecoor(i,2),handles.elecoor(i,3),...
                'o','markersize',8,'MarkerFaceColor',[51 45 130]/255,'MarkerEdgeColor','none');%all electrodes
            if ~isnan(colors(handles.order(i),1))
                set(ehandles(i),'markerfacecolor',colors(handles.order(i),:));%colored electrodes
            end
    end
    set(ax,'nextplot','replace');
    
end
set(ax,'color',[0.98 0.98 0.98]);set(gcf,'color',[0.98 0.98 0.98]);
axis(ax,'tight');
axis(ax,'equal');
axis(ax,'off');axis(ax,'vis3d');
cl = camlight('headlight');
rotate3d off;
%set(gcf,'windowbuttondownfcn',{@change_angle,cl});
set(gcf,'windowbuttondownfcn',{@change_cam,cl});

end


function change_cam(varargin)
ax = gca;
cl = varargin{3};
rotate3d on;
pause(1);
waitfor(ax,'CameraPosition');
rotate3d off;
campo = ax.CameraPosition;
cl.Position = campo;
end