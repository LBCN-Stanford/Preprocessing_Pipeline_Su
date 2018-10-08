function handles = checkBoxCallback(hObject,eventdata,checkBoxId,handles)
hObject_b = hObject;
%handles = guidata(gcf);
    handles.sel_cond(checkBoxId) = get(hObject_b,'Value');
    ax = handles.axes1;
plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page),...
    handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),ax);
%guidata(hObject, handles);