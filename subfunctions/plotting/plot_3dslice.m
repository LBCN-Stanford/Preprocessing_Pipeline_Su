function  plot_3dslice(handles)
if isempty(handles.V)
    return;
end
V = handles.V;
xyz = handles.elecMatrix;
[d1, ~, ~] = size(V);
vol = zeros(size(V));
for i = 1:d1
    vol(i,:,:)=V(:,i,:);
end
V=vol./max(vol(:));
axes(handles.axes3);
vol3d('cdata',V,'texture','3D');
colormap(gray);
view(3); 
axis vis3d
axis equal off
set(gca,'color',[0 0 0]);
%s = slice(V,xyz(handles.page,1),xyz(handles.page,2),xyz(handles.page,3),'edgecolor','none');colormap(gray);
hold on
for j=1:size(handles.group,1)
    type = char(handles.m(handles.group(j,1),1));
    if strcmpi(type(2),'s') || strcmpi(type(2),'g')
        xyz=handles.elecMatrix.*1.01;
        [side,top,~]=scatter3d(xyz(handles.group(j,1):handles.group(j,2),1),...
            xyz(handles.group(j,1):handles.group(j,2),2),...
            xyz(handles.group(j,1):handles.group(j,2),3),...
            handles.elecRgb(handles.group(j,1),:),2,1,5,0,handles.head_center);
        
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

        plot3(xyz(handles.group(j,1):handles.group(j,2),1),xyz(handles.group(j,1):handles.group(j,2),2),...
             xyz(handles.group(j,1):handles.group(j,2),3),...
            '.','markersize',15,'color',handles.elecRgb(handles.group(j,1),:));
    end
    hold on
end

% if ~handles.showslice
%     set(s,'visible','off');
% end