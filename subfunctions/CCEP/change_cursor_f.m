function change_cursor_f(type)
% set(gcf,'pointer','arrow');
% C=get(gcf,'CurrentPoint');
% %P=getpixelposition(handles.axes_dist);
% if C(1)>4 && C(1)<54 && C(2)>2.5 && C(2)<14
%     set(gcf,'pointer','crosshair');
% else 
%     set(gcf,'pointer','arrow');
% end


C=get(gcf,'pointer');
%P=getpixelposition(handles.axes_dist);
if strcmpi(C,'arrow')
    set(gcf,'pointer',type);
else
    set(gcf,'pointer','arrow');
end


%