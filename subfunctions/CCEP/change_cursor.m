function change_cursor(varargin)
set(gcf,'pointer','arrow');
C=get(gcf,'CurrentPoint');
%P=getpixelposition(handles.axes_dist);
if C(1)>4 && C(1)<54 && C(2)>2.5 && C(2)<14
    set(gcf,'pointer','crosshair');
else 
    set(gcf,'pointer','arrow');
end
end