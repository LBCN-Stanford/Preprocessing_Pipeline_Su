function move_slice_b(handles)
V = handles.V;
[d1, d2, d3] = size(V);
ll = handles.page;
xyz=zeros(size(handles.elecMatrix));
xyz(:,1)=handles.elecMatrix(:,2);
xyz(:,2)=handles.elecMatrix(:,1);
xyz(:,3)=d3-handles.elecMatrix(:,3);
 hXslice=handles.slice(1);
    hYslice=handles.slice(2);
    hZslice=handles.slice(3);
mt = ones(d1,d1);   
set(hXslice,'CData',squeeze(V(:,xyz(ll,1),:)));

set(hYslice,'CData',squeeze(V(xyz(ll,2),:,:)));

set(hZslice,'CData',squeeze(V(:,:,xyz(ll,3))));

set(hXslice,'xdata',xyz(ll,1)*mt);

set(hYslice,'ydata',xyz(ll,2)*mt);

set(hZslice,'zdata',xyz(ll,3)*mt);
