%LBCN_viewer_getInitParam
% fprintf('%s\n','---- Please select HFB data file  ----');
%     [filename,pathname] = uigetfile({'*.mat','Data format (*.mat)'},...
%         'MultiSelect', 'on');
%     fname = fullfile(pathname,filename);
%     if iscell(fname)
%         evtfile = fname;
%     else
%         L = load(fname);
%         if isfield(L,'beh_fp')
%             D = L.D;
%             evtfile = L.evtfile;
%             bch = L.bch;
%             signal_all = L.beh_fp;
%             labels = L.labels;
%             plot_cond = L.plot_cond;
%             fprintf('%s\n','-------- Epoched signal loaded --------');
%             exclude = L.exclude;
%             exclude_ts = L.exclude_ts;
%             conditionList = L.conditionList;
%             plot_cond = L.plot_cond;
%         else
%             fprintf('%s\n','-------- Data in matrix. Will compute the HFB only --------');
%             return;
%         end
%     end
% handles.sparam = 25;
% %handles.labels = varargin{3};
% 
% D = meeg;
% D = struct(D);
% 
% %% Set key information first: type, fname, path, Fsample, timeOnset
% 
% D.type = '' ;
% 
% D.fname = 'Empty.mat';
% D.path = pth;
% D.timeOnset = 0;
% D.Fsample = header.samplerate(1);
% 
% 
% 
% handles.D = varargin{4} ;
% handles.window = varargin{5};
% handles.plot_cond = varargin{6} ;
% handles.page = varargin{7};
% handles.yl = varargin{8};
% handles.bch = varargin{9};
% handles.t = varargin{10};
% setappdata(hObject,'signal_other',varargin{11});
% handles.bc_type = varargin{12};