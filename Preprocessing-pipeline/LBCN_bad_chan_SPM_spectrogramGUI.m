function LBCN_bad_chan_SPM_spectrogramGUI(h_fig,D,data_pxx,freqs)
% Function to display spectrograms as computed by LBCN_plot_power_spectrum.
% The display is split in 2: one part displaying the good channels and one
% part displaying the bad channels. It is interactive and will pass
% channels from the 'good' to the 'bad' side on the graph with a click. In
% addition, the SPM MEEG object is updated and the new 'bad' channel
% selection is saved in the object.


% Check inputs
if nargin<1
   h_fig=[]; 
end

if nargin <2 && isempty(D)
    error('Please provide MEEG object as input');
end

if nargin <3 && isempty(data_pxx)
    error('Please provide matrix of psd data as input');
end

if nargin<4 || isempty(freqs)
    freqs = 1:size(data_pxx,1);
end

% Prepare figure
if isempty(h_fig)
    h_fig=figure; clf;
    ax_lims=[];
else
    figure(h_fig); 
    ax_lims=get_subplot_xy_lims(h_fig);
    clf;
end
set(h_fig,'position',[100 300 800 400],'paperpositionmode','auto');


% Get good and bad channels
% [n_freq,n_chan]=size(data_pxx);
good_chan_ids=indchantype(D,'EEG','good');
bad_chan_ids=indchantype(D,'EEG','bad');
n_bad=length(bad_chan_ids);

% Current good channels subplot
subplot(1,2,1);
h=plot(freqs,data_pxx(:,good_chan_ids));
chan_ct=0;
for a=h',
    chan_ct=chan_ct+1;
    clear udata;
    udata.chan_name=chanlabels(D,good_chan_ids(chan_ct));
    udata.h_fig=h_fig;
    udata.D = D;
    udata.data_pxx = data_pxx;
    udata.freqs = freqs;
    udata.chan_ct = chan_ct;
    udata.good_chan_ids = good_chans_ids;
    set(a,'userdata',udata);
    bdfcn=['udata=get(gcbo,''userdata'');', ...
        'fprintf(''Labelling %s as bad.\n'',udata.chan_name{1});' ...
        'udata.D=badchannels(udata.D,good_chan_ids(udata.chan_ct),1);' ...
        'f_udata=get(gcf,''userdata'');', ...
        'f_udata.vL=axis();' ...
        'set(gcf,''userdata'',f_udata);' ...
        'bad_chan_GUI(udata.h_fig, udata.D,udata.data_pxx,udata.freqs);'];
    set(a,'buttondownfcn',bdfcn);
end
% hh=xlabel('Frequency (Hz)');
% hh=ylabel('10*log10(/muV^2/Hz)');

% Mark the harmonics of 60 Hz
hold on;
v=axis;
ct=1;
lnnz=60;
while lnnz<=max(freqs) && lnnz>=min(freqs)
    plot([1 1]*lnnz,v(3:4),'k--');
    ct=ct+1;
    lnnz=60*ct;
end
ht=title('Current Good Channels');
set(ht,'buttondownfcn','axis tight');   

if ~isempty(ax_lims),
   axis(ax_lims(2,:)); 
end

% Current bad channels subplot
subplot(1,2,2);
if n_bad==0,
    v=axis;
    ht=text(mean(v(1:2)),mean(v(3:4)),'No bad channels.');
    set(ht,'horizontalalignment','center');
else
    h=plot(freqs,data_pxx(:,bad_chan_ids));
    chan_ct=0;
    
    for a=h',
        chan_ct=chan_ct+1;
        clear udata;
        udata.chan_name=chanlabels(D,bad_chan_ids(chan_ct));
        udata.h_fig=h_fig;
        udata.D = D;
        udata.data_pxx = data_pxx;
        udata.freqs = freqs;
        set(a,'userdata',udata);
        bdfcn=['udata=get(gcbo,''userdata'');', ...
            'fprintf(''Labelling %s as good.\n'',udata.chan_name{1});' ...
            'udata.D=badchannels(udata.D,bad_chan_ids(chan_ct),0);' ...
            'f_udata=get(gcf,''userdata'');', ...
            'f_udata.vR=axis();' ...
            'set(gcf,''userdata'',f_udata);' ...
            'bad_chan_GUI(udata.h_fig,udata.D,udata.pdata_xx,udata.freqs);'];
        set(a,'buttondownfcn',bdfcn);
    end
    
    % Mark the harmonics of 60 Hz
    hold on;
    v=axis;
    ct=1;
    lnnz=60;
    while lnnz<=max(freqs) && lnnz>=min(freqs)
        plot([1 1]*lnnz,v(3:4),'k--');
        ct=ct+1;
        lnnz=60*ct;
    end
end
% hh=xlabel('Frequency (Hz)');
% hh=ylabel('10*log10(/muV^2/Hz)');
ht=title('Current Bad Channels');
set(ht,'buttondownfcn','axis tight'); 

% if ~isempty(vR),
%    axis(vR); 
% end
if ~isempty(ax_lims),
   axis(ax_lims(1,:)); 
end
set(gcf,'name',D.fname);

% Done button to terminate the bad channel selection
h = uicontrol('Position',[10 7000 100 30],'String','Done',...
              'Callback','uiresume(gcbf)');
          
uiwait(h_fig)
delete(h_fig)

