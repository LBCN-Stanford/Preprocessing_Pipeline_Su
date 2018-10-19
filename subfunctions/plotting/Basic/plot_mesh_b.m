function handles = plot_mesh_b(handles, surfpath)
if isstruct(surfpath)
    s = surfpath.right;
else
    if ~exist(fullfile(surfpath,'rh.pial'),'file') || isempty(handles.elecoor)
        return;
    end
    [hi.vertices, hi.faces] = freesurfer_read_surf(fullfile(surfpath,'rh.pial'));
    s.tri= hi.faces;s.vert=hi.vertices;
end
if strcmp(char(handles.m(1,1)),'d')
        alpha = 0.6;
    else
        alpha = 0.15;
end
temp=tripatchDG(s,1);
if size(s.vert,1)>2000000
    model=reducepatch(temp,0.1);
elseif size(s.vert,1)>1000000
    model=reducepatch(temp,0.5);
else
    model.vertices=get(temp,'Vertices');
    model.faces=get(temp,'Faces');
end
delete(temp);
handles.model(handles.overlay).faces=model.faces;
handles.model(handles.overlay).vertices=model.vertices;

hi.tri=handles.model(handles.overlay).faces;
hi.vert=handles.model(handles.overlay).vertices;

handles.isrender=1;

axes(handles.axes3);
handles.rh=tripatchDG(hi,1,'facecolor',[0.85 0.85 0.85],'clipping','on',...
    'DiffuseStrength',  0.7, ...
    'facealpha',alpha, 'edgecolor' , 'none');
%shading interp;
lighting gouraud; material dull;
hold on

handles.overlay = handles.overlay+1;

if isstruct(surfpath)
    s = surfpath.left;
else
    [hi.vertices, hi.faces] = freesurfer_read_surf(fullfile(surfpath,'lh.pial'));
    s.tri= hi.faces;
    s.vert=hi.vertices;
end
temp=tripatchDG(s,1);
if size(s.vert,1)>2000000
    model=reducepatch(temp,0.1);
elseif size(s.vert,1)>1000000
    model=reducepatch(temp,0.5);
else
    model.vertices=get(temp,'Vertices');
    model.faces=get(temp,'Faces');
end
delete(temp);
handles.model(handles.overlay).faces=model.faces;
handles.model(handles.overlay).vertices=model.vertices;

hi.tri=handles.model(handles.overlay).faces;
hi.vert=handles.model(handles.overlay).vertices;

handles.isrender=1;
axes(handles.axes3);
handles.lh=tripatchDG(hi,1,...
    'DiffuseStrength',  0.7, ...
    'facealpha',alpha, 'edgecolor' , 'none');
shading interp; lighting gouraud; material dull;
hold on
set(handles.lh,'facecolor',[0.87 0.87 0.87]);
set(handles.rh,'facecolor',[0.87 0.87 0.87]);
hold on
view(handles.elecoor(5,:));
handles.light = camlight('headlight');
handles.head_center=[0 0 0];


e = zeros(1,size(handles.group,1));
if size(handles.elecoor,1) ~= handles.group(end)
    disp('Electrode number mismatch, correcting..');
    handles.group(end) = size(handles.elecoor,1);
end
for j=1:size(handles.group,1)
    
    type = char(handles.m(handles.group(j,1),1));
    if strcmpi(type(2),'s') || strcmpi(type(2),'g')
        handles.elecoor=handles.elecoor.*1.01;
        [side,top,~]=electrode3d(handles.elecoor(handles.group(j,1):handles.group(j,2),1),...
            handles.elecoor(handles.group(j,1):handles.group(j,2),2),...
            handles.elecoor(handles.group(j,1):handles.group(j,2),3),...
            handles.elecRgb(handles.group(j,1),:),2.5,0,5,0,handles.head_center);
        
        handles.curr_elec.side=patch('faces',side.faces,'vertices',...
            side.vertices,'edgecolor','none','facecolor',(handles.elecRgb(handles.group(j,1),:)),'facelighting',...
            'gouraud');
        
        e(j)=patch('faces',top.faces,'vertices',...
            top.vertices,'edgecolor','none','facecolor',handles.elecRgb(handles.group(j,1),:),'facelighting',...
            'gouraud',...
            'DiffuseStrength',  0.5, ...
            'SpecularStrength', 0.1, ...
            'SpecularColorReflectance', 0.2);
    elseif strcmpi(type(2),'d')
        
        e(j) = plot3(handles.elecoor(handles.group(j,1):handles.group(j,2),1),handles.elecoor(handles.group(j,1):handles.group(j,2),2),...
            handles.elecoor(handles.group(j,1):handles.group(j,2),3),...
            '.','markersize',15,'color',handles.elecRgb(handles.group(j,1),:));
    end
    hold on
end
try
    legend(e, handles.groupNames,'Orientation','horizontal','location',...
        'south','AutoUpdate','off','NumColumns',6, 'fontsize',12);
catch
    legend(e, handles.groupNames,'Orientation','horizontal','location',...
        'south','AutoUpdate','off', 'fontsize',12);
end