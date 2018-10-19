function handles = plot_mesh_fig(handles)
% if isstruct(surfpath)
%     s = surfpath.right;
% else
%     if ~exist(fullfile(surfpath,'rh.pial'),'file') || isempty(handles.elecoor)
%         return;
%     end
%     [hi.vertices, hi.faces] = freesurfer_read_surf(fullfile(surfpath,'rh.pial'));
%     s.tri= hi.faces;s.vert=hi.vertices;
% end
if strcmp(char(handles.m(1,1)),'d')
        alpha = 0.15;
    else
        alpha = 0.8;
end
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
handles.overlay = 1;
hi.tri=handles.model(handles.overlay).faces;
hi.vert=handles.model(handles.overlay).vertices;
% 
% handles.isrender=1;
figure;gca;
ax = gca;
%axes(handles.axes3);

lh = tripatchDG(hi,1,'facecolor',[0.87 0.87 0.87],'clipping','on',...
    'DiffuseStrength',  0.8, ...
    'facealpha',alpha, 'edgecolor' , 'none','parent',ax,'FaceLighting','gouraud','FaceColor','interp');
set(ax,'nextplot','add');

handles.overlay = handles.overlay+1;

hi.tri=handles.model(handles.overlay).faces;
hi.vert=handles.model(handles.overlay).vertices;
rh = tripatchDG(hi,1,...
    'DiffuseStrength',  0.8, ...
    'facealpha',alpha, 'edgecolor' , 'none','parent',ax,'FaceLighting','gouraud','FaceColor','interp');%,'lighting','gouraud','material','dull','shading','interp');
shading interp; lighting gouraud; material dull;
hold on
set(lh,'facecolor',[0.87 0.87 0.87]);
set(rh,'facecolor',[0.87 0.87 0.87]);
set(ax,'nextplot','add');
%ax.View=handles.elecoor(5,:);
%handles.light = camlight('headlight');


e = zeros(1,size(handles.group,1));
if size(handles.elecoor,1) ~= handles.group(end)
    disp('Electrode number mismatch, correcting..');
    handles.group(end) = size(handles.elecoor,1);
end
for j=1:size(handles.group,1)
    
    type = char(handles.m(handles.group(j,1),1));
    if strcmpi(type(2),'s') || strcmpi(type(2),'g')
        %handles.elecoor=handles.elecoor.*0.99;
        [side,top,~]=electrode3d(handles.elecoor(handles.group(j,1):handles.group(j,2),1),...
            handles.elecoor(handles.group(j,1):handles.group(j,2),2),...
            handles.elecoor(handles.group(j,1):handles.group(j,2),3),...
            handles.elecRgb(handles.group(j,1),:),2.5,0,5,0,handles.head_center,ax);
        
        handles.curr_elec.side=patch('faces',side.faces,'vertices',...
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
            '.','markersize',15,'color',handles.elecRgb(handles.group(j,1),:),'parent',ax);
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
set(ax,'color',[0.98 0.98 0.98]);set(gcf,'color',[0.98 0.98 0.98]);
axis(ax,'tight');
axis(ax,'equal');
axis(ax,'off');axis(ax,'vis3d');
camlight headlight