% for i=1:214
%     e(:,i)=decimate(eeg(:,i),10);
% end
% eeg=e;
%
%
% cn=214;
%
%
%
% bad=zeros(1,cn);
% for i=1:cn
%     if any(eeg(:,i)>100*median(eeg(:,i))) || std(eeg(:,i))>1000
%         bad(i)=1;
%     end
% end
% bad(pathological_chan_id)=1;
%
%
%
%
function d = montage_commonAvg_local(files,bch)
if nargin<1 || isempty(files)
    files = spm_select([1 Inf],'.mat', 'Select files to process',{},pwd,'.mat');
end

if nargin<2
    bch=[];
end

d = cell(size(files,1),1);

for n = 1:size(files,1)
    % Load file
    D = spm_eeg_load(deblank(files(n,:)));
    % get number of channels and channel labels
    eegchan  = D.indchantype('EEG');
    goodchan = setdiff(eegchan, bch);
    labels = chanlabels(D);
    eeg = D(:,:,:)';
    en=data_norm(eeg,2);
    vn=var(en);vnn=data_norm(vn',5);bch=find(vnn<0.7*median(vnn(vnn~=0)));
    cn = eegchan(end);
    same_group = zeros(1,cn);
    sig_samegroup = eeg(:,1);
    sig_samegroup_avgAll = [];
    groupNo = 1;
    groupID{1}=1;
    groupRef{1}=1;
    
    for i=2:cn
        name= labels{i};
        if strncmp(labels{i-1},name,2)
            same_group(i) = 1;
            groupID{groupNo} = [groupID{groupNo} i];
%             if ~ismember(i,bch)
%                 sig_samegroup=[sig_samegroup eeg(:,i)];
%             end
            groupRef{groupNo} = [groupRef{groupNo} i];
        else
            %groupAvg(:,groupNo) = mean(sig_samegroup,2);
            groupRef{groupNo}(ismember(groupRef{groupNo} ,bch))=[];
            groupNo = groupNo + 1;
            groupID{groupNo} = i;
            groupRef{groupNo} = i;
            
            %sig_samegroup = eeg(:,i);
            
        end 
    end
    tra = eye(length(eegchan));
    for j = 1:groupNo
        tra(groupID{j},groupRef{j}) = tra(groupID{j},groupRef{j}) - 1/length(groupRef{j});
        %tra(badind,refind)  = tra(badind,refind)  - 1/length(refchan);
    end
    montage             = struct();
        montage.labelorg    = D.chanlabels(eegchan);
        montage.labelnew    = D.chanlabels(eegchan);
        montage.chantypeorg = lower(D.chantype(eegchan)');
        montage.chantypenew = lower(montage.chantypeorg);
        montage.chanunitorg = D.units(eegchan)';
        montage.chanunitnew = montage.chanunitorg;
        montage.tra = tra;
        paths = D.path;
        save([paths,filesep,'Montage.mat'],'montage')
        montage_name = [paths,filesep,'Montage.mat'];
        if n==1
            spm_jobman('initcfg')
            spm('defaults', 'EEG');
        end
    jobfile = {which('Montage_NKnew_SPM_job.m')};
    input_array{1} = {deblank(files(n,:))};
    input_array{2} = {deblank(montage_name)};
    [out] = spm_jobman('run', jobfile,input_array{:});
    d{n} = out{end}.D;
    
    % Rewrite the channels as EEG
    save(d{n});
end

% labels = chanlabels(D);
% eeg = D(:,:,:)';
% cn = eegchan(end);
% same_group = zeros(1,cn);
% sig_samegroup = eeg(:,1);
% sig_samegroup_avgAll = [];
% groupNo = 1;
% groupID{1}=1;
% groupRef{1}=1;
% 
% for i=2:cn
%     name= labels{i};
%     if strncmp(labels{i-1},name,2)
%         same_group(i) = 1;
%         groupID{groupNo} = [groupID{groupNo} i];
%         if ~ismember(i,bch)
%             sig_samegroup=[sig_samegroup eeg(:,i)];
%         end
%         groupRef{groupNo} = [groupRef{groupNo} i];
%     else
%         groupAvg(:,groupNo) = mean(sig_samegroup,2);
%         groupRef{groupNo}(ismember(groupRef{groupNo} ,bch))=[];
%         groupNo = groupNo + 1;
%         groupID{groupNo} = i;
%         groupRef{groupNo} = [i];
%         
%         sig_samegroup = eeg(:,i);
%         
%     end
%     
% end
% 
% 
% currg=0;
% for i=1:cn
%     if same_group(i)==0
%         currg=currg+1;
%     end
%     try
%         eeg_m(:,i)=eeg(:,i)-groupAvg(:,currg);
%     catch
%     end
% end
% 
% %
% % onsets=beh_ts*fs;
% % clear alligned
% % clear allignedIndex
% % for i=1:214
% %     [alligned(:,:,i),allignedIndex,~] = getaligneddata(eeg_m(:,i),round(onsets),[-300 900]);
% % end
% %
% % data = alligned;
% % cn = size(data,3);
% % tn = size(data,2);
% % total = cell(cn,1);
% % for i=1:cn
% %     for j=1:tn
% %         total{i}(:,j)=data(:,j,i);
% %     end
% % end
% %
% % plot_cond=1:3;
% %
% % %     beh_ts=[];
% % %     for i=plot_cond
% % %
% % %         beh_ts=[beh_ts events.categories(i).start*fs];
% % %     end
% % %
% % %     beh_no=[];
% % %     for i=plot_cond
% % %         beh_no=[beh_no events.categories(i).numEvents];
% % %     end
% %
% % conditions=beh_no;
% %
% % for i=1:cn
% %     m=1;
% %     for k = 1:length(plot_cond)
% %         conid= find(conditions==plot_cond(k));
% %         total_raw{m}{i}=total{i}(:,conid);
% %         m=m+1;
% %     end
% % end
% % total_plot=total_raw;
% %
% %
% %
% %
% %
% % %
% % %      for i = 1:cn
% % %         m = 1;
% % %         for k = 1:length(plot_cond)
% % %             if k~=1
% % %                 ex=exclude{N}{i}(double(exclude{N}{i}<sum(beh_no(1:k))) == double(exclude{N}{i}>sum(beh_no(1:k-1))+1));
% % %                 total_raw{N}{m}{i}=total{i}(:,sum(beh_no(1:k-1))+1:sum(beh_no(1:k)));
% % %                 total_raw{N}{m}{i}(:,ex-sum(beh_no(1:k-1)))=[];
% % %             else
% % %                 ex=exclude{N}{i}((exclude{N}{i}<beh_no(1)));
% % %                 total_raw{N}{m}{i}=total{i}(:,1:beh_no(1));
% % %                 total_raw{N}{m}{i}(:,ex)=[];
% % %             end
% % %             m=m+1;
% % %         end
% % %      end
% %
% %
% %
% % Nt=length(plot_cond);
% % event_beh=total_plot;
% %
% % beh_f=cell(1,Nt);
% % beh_fp=cell(1,Nt);
% % beh_fps=cell(1,Nt);
% %
% %
% %
% % [b,a] = butter(2,[80 150]/(fs/2));
% % [b2,a2] = butter(2,16/(fs/2),'high');
% % sparam = 60;
% % for ii = 1:Nt
% %     beh_f{ii} = cell(1,cn);
% %     beh_fp{ii} = cell(1,cn);
% %     beh_fps{ii} = cell(1,cn);
% %     for i = 1:cn
% %
% %         badind = [];
% %
% %         %%%%%%%%%%% check data qualit %%%%%%%%%%%%%%%%%
% %         [badind,filtered_beh] = LBCN_filt_bad_trial(event_beh{ii}{i},fs);
% %         beh = filtfilt(b,a,filtered_beh);
% %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %         %beh = filtfilt(b,a,event_beh{ii}{i});
% %         p1 = beh.^2;
% %         p2 = p1(1:200);
% %         p1 = envelope(p1-mean(p2),fs);
% %         beh_f{ii}{i}=beh;
% %         beh_fp{ii}{i}=p1;
% %         badind = zeros(1,size(p1,2));
% %         for j=1:size(p1,2)
% %             ss=smooth_sig(p1(:,j),32,2,1);
% %             ss=ss(30:end-30);
% %             beh_fps{ii}{i}(:,j)=ss;
% %             checkss=filtfilt(b2,a2,ss);
% %             if any(ss>10*median(ss))||... %std(ss)<0.1 ||std(ss)>100 ||
% %                     any(checkss(80:end-80)>7*std(checkss(80:end-80)))
% %                 badind(j) = 0;
% %             end
% %         end
% %         beh_f{ii}{i} = beh(:,~badind);
% %         beh_fp{ii}{i} = p1(:,~badind);
% %         beh_fps{ii}{i} = beh_fps{ii}{i}(:,~badind);
% %     end
% % end
% 
% %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save_print = 0;
% 
% time_start = -0.3;
% time_end = 0.8;
% type = 1;
% 
% 
% chanp=1:cn;
% signal_all=beh_fp;
% t=(0:1000/size(signal_all{1}{1},1):1000)/1000+time_start;
% t(1)=[];
% ign=round(50*size(signal_all{1}{1},1)/1000);
% cc = linspecer(Nt);
% 
% if save_print
%     mkdir('New figures');
% end
% same_group=zeros(1,cn);
% sig_samegroup = [];
% sig_samegroup_avgAll = [];
% 
% 
% 
% plotz=1;
% currGroup=1;
% figure;
% set(gcf,'Position',[400 500 600 400]);
% set(gcf,'color',[1 1 1]);
% clear temp_mean
% clear temp_std;
% for i=chanp
%     name= D.channels(i).label;
%     if contains(lower(name), 'ekg') || contains(lower(name), 'edf') || contains(lower(name), 'ref')
%         continue;
%     end
%     cla;
%     allcond=true(Nt,1);
%     temp_mean = [];
%     for j=1:Nt
%         signal_z=zscore(signal_all{j}{i}(ign:(end-ign),:));
%         signal_org=(signal_all{j}{i}(ign:(end-ign),:));
%         if plotz==1
%             signal=signal_z;
%         else
%             signal=signal_org;
%         end
%         if isempty(signal) || size(signal,2) == 1
%             %title(['Channel ',num2str(i),'  ',char(chanlabels(D{1},chanp(i))),' ','Ignoring bad cond.']);
%             allcond(j)=0;
%             continue;
%         end
%         nt=size(signal,2);
%         elim=false(1,nt);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         for nc=1:nt
%             if any(signal(:,nc)>50*abs(median(signal(:)))) || max(signal_org(:,nc))>1000
%                 %aaaa=0;
%                 elim(nc)=1;
%             end
%         end
%         %         [badind] = LBCN_filt_bad_trial2(signal,1000,5,10);
%         %         if ~any(~badind)
%         %             continue;
%         %         end
%         temp_mean(:,j ) = mean(signal(:,~elim),2);
%         temp_mean(:,j ) = smooth_sig(temp_mean(:,j ),sparam,2,1);
%         temp_std(:,j ) = std((signal(:,~elim)'),1)/(nt);
%         temp_std(:,j ) = smooth_sig(temp_std(:,j ),sparam,2,1);
%         before_samples=round(length(signal)/1000*(-(-0.2*1000)));
%         if plotz == 1
%             try
%                 shift(j)=0.8*min((temp_mean(ign:before_samples,j)))-0;
%             catch
%                 allcond(j)=0;
%                 continue
%             end
%         else
%             shift(j)=min((temp_mean(before_samples-50:before_samples+10,j)))-0;
%         end
%         try
%             plot(t(ign:end-ign),temp_mean(:,j)-shift(j),'color',cc(j,:),'linewidth',2);
%             hold on
%         catch
%             allcond(j)=0;
%             continue
%         end
%     end
%     if isempty(temp_mean)
%         continue;
%     end
%     legend(labs(plot_cond(allcond)),'Location','NorthEastOutside');
%     for j=1:Nt
%         try
%             shadedErrorBar(t(ign:end-ign),temp_mean(:,j)-shift(j),temp_std(:,j),'color',cc(j,:),1);
%         catch
%             continue
%         end
%     end
%     if ismember(chanp(i),pathological_chan_id)
%         isgood = 'Might be in the irritative zone';
%     else
%         isgood = 'Normal';
%     end
%     title(['Channel ',num2str(i),'  ',name,'  (',isgood,')']);
%     set(gca,'linewidth',2,'fontsize',16);
%     line([time_start time_end],[0 0],'LineWidth',2,'Color','k');
%     if type == 2
%         if ~same_group(i)
%             yl_currGroup1=(yl1(currGroup))*0.3;
%             yl_currGroup2=(yl2(currGroup))+max(shift);
%             currGroup = currGroup+1;
%         end
%     elseif type == 1
%         yl_currGroup1=-0.25;
%         yl_currGroup2=1.75;
%     end
%     line([0 0],[yl_currGroup1 yl_currGroup2],'color','k','linewidth',2);
%     xlim([time_start+0.08 t(end)-0.08]);
%     if plotz == 1
%         try
%             ylim([yl_currGroup1 yl_currGroup2])
%         catch
%             continue
%         end
%     end
%     hold off
%     box off
%     legend(labs(plot_cond(allcond)),'Location','NorthEastOutside');
%     if save_print
%         print('-opengl','-r300','-dpng',strcat('New figures','/','S18_123','_',name,'_EmotionalFaces'));
%     else
%         pause;
%     end
% end