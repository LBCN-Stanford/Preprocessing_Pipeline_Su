function LBCN_plot_averaged_signal_epochs2(fname,indchan,conds,timewin, save,task,colors,labels,exclude,bch,removeid)

% Function to plot the mean and standard error of the signal for each
% condition, on one channel.
% Inputs:
% - fname     : name of file to display (SPM format)
% - indchan   : index or name of the channel to plot (default: 1st channel)
% - conds     : indexes of conditions to display or cell array of condition
%               names. Default: all conditions in file
% - timewin   : time window to display (in ms). Default: all time points
% - save      : save the plots in a 'figs' subdirectory of the file name
%               path (Default: Yes, 1)
% suffix      : specific suffix for saving the plots
% colors      : color matrix for plot
% Outputs:
% Plots of the signal average and standard error for each condition. One
% plot per channel. Those plots can be saved automatically if wanted.
% -------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, Stanford, 10/28/2015

% Get inputs
% -----------

if nargin<1 || isempty(fname)
    [fname,fpath] = spm_select(1,'mat','Select file to display',{},pwd,'.mat');
end
D = spm_eeg_load(fname);
[parfile] = find_file(fpath,'/Params_*.mat',fname(21:end));
if ~isempty(parfile)
    load(parfile);
    try
    LBCN_plot_averaged_signal_epochs2(fname,[],plot_cond,twsmooth, 0,[],[],[],EXCLUDE,BCH,REMOVEID);
    return;
    catch
    end
end


if nargin<2 || isempty(indchan)
    indchan = 1:D.nchannels;
elseif iscellstr(indchan)
    indchan = indchannel(D,indchan);
end
subcat = 0;
if nargin<3 || isempty(conds)
    labs = D.condlist;conds=1:length(labs);
elseif iscellstr(conds) || strcmp(conds,'subcat')
    labs=[{'faces'} {'bodies'} {'buildings & scenes'} {'numbers'} ...
            {'words'} {'logos & shapes'} {'other'}];
     subconds{1}=[5 7 9];
     subconds{2}=[6 8 10];
     subconds{3}=[13 19];
     subconds{4}=[4];
     subconds{5}=1;
     subconds{6}=[12 14];
     subconds{7}=[2 3 11 15:18 20];
     conds = 1:6;
     labs=labs(conds);
     subcat=1;
elseif iscellstr(conds) || iscell(conds)
    labs = conds;
else
    listcond = condlist(D);
    labs  =listcond(conds);
end

if nargin<4 || isempty(timewin)
    time_start = min(time(D));
    tt(1) = indsample(D,time_start);
    time_end = max(time(D));
    tt(2) = indsample(D,time_end);
else
    tt(1) = indsample(D,timewin(1)/1000);
    tt(2) = indsample(D,timewin(2)/1000);
    time_start = time(D,tt(1));
    time_end = time(D,tt(2));
end

if nargin<5 || isempty(save)
    save = 0;
end
  
if nargin<6 
    task = identify_task(fpath);
end

if nargin<7 || isempty(colors)
    colors = colormap(lines(length(labs)-1));
    colors = [[200 10 150]/255; colors]; % pink
else
    if size(colors,1)< length(labs) 
        disp('Number of colors provided smaller than number of conditions to plot')
        disp('Completing with Matlab built-in')
        addc = size(colors,1)-length(labs);
        colors = [colors; colormap(lines(addc))];
    end
end 
  
if nargin<8 || isempty(labels)
    labels = labs;
end

if nargin<9 || isempty(exclude)
    exclude = cell(1,D.nchannels);
end

if nargin<10 
    bch = [];
end


if nargin<11 || isempty(removeid)
    removeid = zeros(size(D(:,:,:)));
end

fs=fsample(D); 
for i=1:length(labels)
    labels{i}(ismember(labels{i},'_'))=' ';
end
% Plot traces
% -----------
%[b,a]=butter(2,[16 70]/500);
tim =time(D);
idt = tt(1):tt(2);  

if numel(size(D)) == 4
    ifreq = 1;
    disp('Plotting for first frequency')
    itf = 1;
else
    itf = 0;
end

plot_max = zeros(length(labs),1);
plot_min = zeros(length(labs),1);
fprintf(['Plotting channel (out of %d):',repmat(' ',1,ceil(log10(length(indchan)))),'%d'],length(indchan), 1);
if ~save
    hfig =figure;
    set(gcf,'Position',[400 500 800 500]); 
    hold on
end
badsig=cell(1,length(conds));
%sparam1=60;
sparam2=25;
for i=1:length(indchan)
    name=chanlabels(D);
    name=name{i};
    if contains(lower(name), 'ekg') || contains(lower(name), 'edf') || contains(lower(name), 'ref')
        continue;
    end
    cla;
    allcond=true(length(conds),1);
    % Counter of channels to be updated
    if i>1
        for idisp = 1:ceil(log10(i)) % delete previous counter display
            fprintf('\b');
        end
        fprintf('%d',i);
    end
    if save
    hfig =figure;
    set(gcf,'Position',[300 400 700 400]); 
    hold on
    end
    % First plot the signal to create the legend
    for kk = 1:length(conds)
        if subcat
            list=D.condlist;
            bad = [];
            tr_toplot = [];
            for s = subconds{conds(kk)}
                try
                ex=exclude{i}(1,all(exclude{i}));
                catch
                    ex=[];
                end
                bad=[bad ex(ismember(ex,(indtrial(D,list{s}))))];
                tr_toplot = [tr_toplot setdiff(indtrial(D,list{s}),[badtrials(D) bad])]; %take bad trials out
            end
        else 
            try
                ex=exclude{i}(1,all(exclude{i}));
            catch
                    ex=[];
            end
        bad=ex(ismember(ex,(indtrial(D,labs{kk}))));
        tr_toplot = setdiff(indtrial(D,labs{kk}),[badtrials(D) bad]); %take bad trials out
        end
        if itf
            mcond = squeeze(mean(D(indchan(i),itf,idt,tr_toplot),4));
        else
            remove = squeeze(removeid(i,:,tr_toplot));
            sig = squeeze(D(indchan(i),idt,tr_toplot));
            sig(logical(remove))=nan;
            atf=false(size(sig,2),1);
            vs=nanvar(sig);
            atf(vs>5*nanmedian(vs(vs~=0)))=1;
            badsig{kk}=atf;
            sig=sig(:,~atf);
            %sig=sig(30:end-30,:);
            signal{kk}=sig;
            trplot{kk}=tr_toplot;
            try
                mcond=nanmean(sig,2);
                window=~isnan(mcond);
                ms=smooth_sig(mcond(window),sparam2,3,1);
            catch
                allcond(kk)=0;
                continue;
            end
        end
        shift(kk)=0;%mean((ms(1:200)))-0;
        %mcond = fastsmooth(mcond,36,2,6);
        tt=tim(idt);
        tt=tt(window);
        plot(tt,ms-shift(kk), 'Linewidth',2,'Color',colors(kk,:));
        hold on;
    end
    % Add standard error for each channel
    for kk = 1:length(conds)
         tr_toplot = trplot{kk};
            sig=signal{kk};
            try
                mcond=nanmean(sig,2);
                stdcond=nanstd(sig')/sqrt(length(tr_toplot)); 
                ms=smooth_sig(mcond(window),sparam2,3,1);
                stdcond=smooth_sig(stdcond(window),sparam2,3,1);
                 shift(kk)=0;%mean((ms(1:200)))-0;
            catch
                allcond(kk)=0;
                continue;
            end
%        end
        
        if ~isempty(~isnan(mcond)) && any(~isnan(stdcond)) && size(stdcond',1)~=1
            shadedErrorBar2(tt,ms-shift(kk),stdcond,{'linewidth',2,'Color',colors(kk,:)},0.8);
            %for axis below
            plot_max(kk,:) = max(ms+stdcond');
            plot_min(kk,:) = min(ms-stdcond');
        else
            allcond(kk)=0;
            continue;
        end
        hold on
    end
    if ~any(allcond)
        continue;
    end
    xlim([tt(1)+30/fs tt(end)-200/fs]);
    yl=get(gca,'ylim');
    %try
    %ylim([min(plot_min)-min(plot_min)*-.10 max(plot_max)+max(plot_max)*.10]);
    if yl(2)<2.5 && yl(1)>-0.6
        ylim([-0.5 2.5]);
    elseif  yl(2)<2.5 && yl(1)<-0.6
        ylim([min(plot_min)-min(plot_min)*-.10 2.5]);
    elseif  yl(2)>2.5 && yl(1)>-0.6
        ylim([-0.5 max(plot_max)+max(plot_max)*.10]);
    else
       % ylim([min(plot_min)-min(plot_min)*-.10 max(plot_max)+max(plot_max)*.10]);
    end
    yl=get(gca,'ylim');
    %add lines
    %zero level
    line([time_start time_end],[0 0],'LineWidth',2,'Color','k');
    % %stim onset
    line([0 0],[yl(1) yl(2)],'LineWidth',2,'Color','k'); %stim onset;
    
    legend(labels(allcond),'Location','NorthEastOutside');
    %figure properties
    hold off
    box off
    %catch
    %    continue
    %end
   % ylim([min(plot_min)-min(plot_min)*-.10 2]);
    
    xlabel('Time (s)','fontsize',14);
    ylabel('Signal','fontsize',14);
    if ismember(indchan(i),D.badchannels) && ~ismember(indchan(i),bch)
        isgood = 'bad';
    elseif ismember(indchan(i),bch)
        isgood = 'Might be in the irritative zone';
    else
        isgood = 'Normal';
    end
    
    title(['Channel ',num2str(i),'  ',name,'  (',isgood,')']);
    %title(['Channel ',num2str(i),'  ',name]);
    set(gca,'linewidth',2,'fontsize',16);
    
    % Save figures in a 'figs' subdire ctory
    path = spm_fileparts(fname);
    if save
        if ~exist([path,filesep,'figs'],'dir')
            mkdir(path,'figs');
        end
        print('-opengl','-r300','-dpng',strcat([path,filesep,'figs',filesep,char(chanlabels(D,indchan(i))),'_',task]));
        delete(hfig)
    else
        pause;
        %delete(hfig)
        %cla;
    end
    signal=[];
end
fprintf('\n')
disp('Done: Plot average and standard error for each channel')