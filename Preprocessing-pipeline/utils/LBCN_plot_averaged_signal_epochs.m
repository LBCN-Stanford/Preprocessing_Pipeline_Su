function LBCN_plot_averaged_signal_epochs(fname,indchan,conds,timewin, save,suffix,colors,labels)

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
    fname = spm_select(1,'mat','Select file to display',{},pwd,'.mat');
end
D = spm_eeg_load(fname);

if nargin<2 || isempty(indchan)
    indchan = 1:D.nchannels;
elseif iscellstr(indchan)
    indchan = indchannel(D,indchan);
end

if nargin<3 || isempty(conds)
    labs = D.condlist;
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
    suffix = [];
end

if nargin<7
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
  
if nargin<8 
    labels = labs;
end

fs=fsample(D); 
% Plot traces
% -----------
[b,a]=butter(2,[16 70]/500);
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
%  load('/Users/suliu/Dropbox/MATLAB/LBCN_preprop_alter/exclude2files.mat');    
%exclude=exclude1{1};
exclude=[];%load('matlab.mat');exclude=exclude{1};
fprintf(['Plotting channel (out of %d):',repmat(' ',1,ceil(log10(length(indchan)))),'%d'],length(indchan), 1);
for i=1:length(indchan)
    
    % Counter of channels to be updated
    if i>1
        for idisp = 1:ceil(log10(i)) % delete previous counter display
            fprintf('\b');
        end
        fprintf('%d',i);
    end
    
    hfig =figure;
    set(gcf,'Position',[400 500 800 500]); 
    hold on
    
    
    kk=1;

    % First plot the signal to create the legend
    for sp = [1:9]
        
        
        bad=[];
        try 
            bad=exclude{i}(ismember(exclude{i},(indtrial(D,labs{sp}))));
        catch
        end 
        
        tr_toplot = setdiff(indtrial(D,labs{sp}),[badtrials(D) bad]); %take bad trials out
        %         tr_toplot = tr_toplot([1:5:end]);
        if itf
            mcond = squeeze(mean(D(indchan(i),itf,idt,tr_toplot),4));
        else
            sig = squeeze(D(indchan(i),idt,tr_toplot));
            vs=var(sig);
            atf=vs>10*median(vs(vs~=0));
            atf((sum(sig)==0))=1;
            
            sig=sig(:,~atf);
            for nn=1:size(sig,2)
                sig(:,nn)=smooth_sig(sig(:,nn),30,3,1);
            end
            %sig=zscore(sig(30:end-30,:));
            sig=sig(30:end-30,:);
            try
                %mcond = squeeze(mean(D(indchan(i),idt,tr_toplot(~atf)),3));
                mcond=mean(sig,2);
            catch
                continue;
            end
            kk=kk+1;
        end
        %mcond = fastsmooth(mcond,36,2,6);
        tt=tim(idt);
        plot(tt(30:end-30),mcond, 'Linewidth',2,'Color',colors(sp,:));
    end
    %legend(labels,'Location','NorthEastOutside');
    
    % Add standard error for each channel
    kk=1;
    for sp = [1:9]
        
        bad=[];
        try
            bad=exclude{i}(ismember(exclude{i},(indtrial(D,labs{sp}))));
        catch
        end
        tr_toplot = setdiff(indtrial(D,labs{sp}),[badtrials(D) bad]);
        %         tr_toplot = tr_toplot([1:5:end]); 
        if itf
            mcond = squeeze(mean(D(indchan(i),itf,idt,tr_toplot(~atf)),4));
            stdcond = squeeze(std(D(indchan(i),itf,idt,tr_toplot(~atf)),1,4))/sqrt(length(tr_toplot(~atf)));
        else
            %sig = squeeze(D(indchan(i),idt,tr_toplot(~atf)));
            sig = squeeze(D(indchan(i),idt,tr_toplot));
            vs=var(sig);
            atf=vs>10*median(vs(vs~=0));
            atf((sum(sig)==0))=1;
            
            sig=sig(:,~atf);
            for nn=1:size(sig,2)
                sig(:,nn)=smooth_sig(sig(:,nn),30,3,1);
            end
            sigz=zscore(sig(30:end-30,:));
            sig=sig(30:end-30,:);
            
            try
                %mcond = squeeze(mean(D(indchan(i),idt,tr_toplot(~atf)),3));
                %stdcond = squeeze(std(D(indchan(i),idt,tr_toplot(~atf)),1,3))/sqrt(length(tr_toplot(~atf)));
                mcond=mean(sig,2);
                stdcond=std(sig')/sqrt(length(tr_toplot(~atf)));
            catch
                continue;
            end
        end
        kk=kk+1;
        if ~isempty(~isnan(mcond)) && size(stdcond',1)~=1
            tt=tim(idt);
            shadedErrorBar2(tt(30:end-30),mcond,stdcond',{'linewidth',2,'Color',colors(sp,:)},0.8);
            %for axis below
            plot_max(sp,:) = max(mcond+stdcond');
            plot_min(sp,:) = min(mcond-stdcond');
        end
        hold on
    end
    
    
    %add lines
    %zero level
    line([time_start time_end],[0 0],'LineWidth',1,'Color','k');
    % %stim onset
    line([0 0],[min(plot_min)-min(plot_min)*-.10 max(plot_max)+max(plot_max)*.10],'LineWidth',1,'Color','k'); %stim onset;
    
    
    %figure properties
    hold off
    box off
    xlim([time_start+30/fs time_end-30/fs]);
    try
    ylim([min(plot_min)-min(plot_min)*-.10 max(plot_max)+max(plot_max)*.10]);
    catch
        continue
    end
   % ylim([min(plot_min)-min(plot_min)*-.10 2]);
    
    xlabel('Time (s)','fontsize',14);
    ylabel('Signal','fontsize',14);
    if ismember(indchan(i),D.badchannels)
        isgood = 'bad';
    else
        isgood = 'good';
    end
    title(['Channel ',char(chanlabels(D,indchan(i))),'  (',isgood,')'],'fontsize',14, 'fontweight','bold')
    
    % Save figures in a 'figs' subdirectory
    path = spm_fileparts(fname);
    if save
        if ~exist([path,filesep,'figs'],'dir')
            mkdir(path,'figs');
        end
        print('-opengl','-r300','-dpng',strcat([path,filesep,'figs',filesep,char(chanlabels(D,indchan(i))),'_',suffix]));
        delete(hfig)
    else
        pause;
        delete(hfig)
    end
    
end
fprintf('\n')
disp('Done: Plot average and standard error for each channel')