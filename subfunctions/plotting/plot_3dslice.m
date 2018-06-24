function  hslices = plot_3dslice(handles)
if isempty(handles.V)
    return;
end
V = handles.V;
[d1, ~, d3] = size(V);
xyz=zeros(size(handles.elecMatrix));
xyz(:,1)=handles.elecMatrix(:,2);
xyz(:,2)=handles.elecMatrix(:,1);
xyz(:,3)=d3-handles.elecMatrix(:,3);
mxY=max(squeeze(V(:,round(d1/2),:)),[],1);
mxX=max(squeeze(V(round(d1/2),:,:)),[],1);
mxZ=max(squeeze(V(:,:,round(d1/2))),[],1);

la=max(intersect(1:(round(d1/2)),find(mxY==0)))*0.9;
lb=max(intersect(1:(round(d1/2)),find(mxX==0)))*0.9;
lc=max(intersect(1:(round(d1/2)),find(mxZ==0)))*0.9;
ld=max(intersect((round(d1/2):d1),find(mxY~=0)))*1.05;
le=max(intersect((round(d1/2):d1),find(mxX~=0)))*1.05;
lf=max(intersect((round(d1/2):d1),find(mxZ~=0)))*1.05;
lim = min([la lb lc]);
lim2 = max([ld le lf]);
axes(handles.axes3);

[x,y,z] = meshgrid(1:size(V,2),1:size(V,1),1:size(V,3));
     
	hslices=slice(x,y,z,V,xyz(handles.page,1),xyz(handles.page,2),xyz(handles.page,3));
    colormap(gray);
    xlabel('x');ylabel('y');zlabel('z');
%     xlim([1 size(V,1)*4]); 
%     ylim([1 size(V,2)*4]);
%     zlim([1 size(V,3)*4]); 
    
    hXslice=hslices(1);
    hYslice=hslices(2);
    hZslice=hslices(3);
    
    set(hXslice,'EdgeColor','None','Tag','SliceX');
    set(hYslice,'EdgeColor','None','Tag','SliceY');
    set(hZslice,'EdgeColor','None','Tag','SliceZ');
   
   	axis tight;	
	axis vis3d;	
    set(gca,'ZDir','reverse');
    set(gca,'YDir','reverse');

%vol3d('cdata',V,'texture','3D');
% colormap(gray);
% view(3); 
% axis vis3d
% axis equal off
% set(gca,'color',[0 0 0]);
%s = slice(V,xyz(handles.page,1),xyz(handles.page,2),xyz(handles.page,3),'edgecolor','none');colormap(gray);
hold on
for j=1:size(handles.group,1)
    type = char(handles.m(handles.group(j,1),1));
    if strcmpi(type(2),'s') || strcmpi(type(2),'g')
        xyz=handles.elecMatrix.*1.01;
        [side,top,~]=scatter3d(xyz(handles.group(j,1):handles.group(j,2),1),...
            xyz(handles.group(j,1):handles.group(j,2),2),...
            xyz(handles.group(j,1):handles.group(j,2),3),...
            handles.elecRgb(handles.group(j,1),:),1.5,1,5,0,handles.head_center);
        
        handles.curr_elec.side=patch('faces',side.faces,'vertices',...
            side.vertices,'edgecolor','none','facecolor',(handles.elecRgb(handles.group(j,1),:)),'facelighting',...
            'gouraud');
        
        handles.curr_elec.top=patch('faces',top.faces,'vertices',...
            top.vertices,'edgecolor','none','facecolor',handles.elecRgb(handles.group(j,1),:),'facelighting',...
            'gouraud',...
            'DiffuseStrength',  0.5, ...
            'SpecularStrength', 0.1, ...
            'SpecularColorReflectance', 0.2);
    elseif strcmpi(type(2),'d')

        e(j) = plot3(xyz(handles.group(j,1):handles.group(j,2),1),xyz(handles.group(j,1):handles.group(j,2),2),...
             xyz(handles.group(j,1):handles.group(j,2),3),...
            '.','markersize',12,'color',handles.elecRgb(handles.group(j,1),:));
    end
    hold on
end
xlim([lim lim2]);
ylim([lim lim2]);
zlim([lim lim2]);
legend(e, handles.groupNames,'location','northeast','AutoUpdate','off', ...
    'box','off','fontsize',12,'NumColumns',ceil(size(handles.group,1)/length(handles.plot_cond)));

% if ~handles.showslice
%     set(s,'visible','off');
% end