
function [feature_matrix,Feature,discard,projection,G_coef,th]=calculate_feature_ccep(data,fs)
%fs=1000;
dn=0.98;
dn2=0.3;
dn3=[-50 0];
xx=1;
op=0;
compare=0;
[b,a]=butter(2,16/round(fs/2),'high');
if fs==1024
    fc=500;
elseif fs==1000  
    fc=450;
else
    fc=floor(fs/2);
end
ii=3;

candidate=cell(1,size(data,3));
pre=125*(fs/1000);
post=126*(fs/1000);


ind=[round(size(data,1)/2-pre):round(size(data,1)/2+post)];
%ld=length(data(:,1,1));
ld=length(ind);
%ex=1;
%elim=[];
for i=1:size(data,3)
   % try
    candidate{i}(:,1)=data(ind,1,i);
    candidate{i}(:,2)=data(ind,2,i);
    candidate{i}(:,3)=i;
    %catch
    %    elim(ex)=i;
    %    ex=ex+1;
    %    continue
end
%candidate(elim)=[];
x=round((length(candidate)/24));
G_coef=zeros(length(candidate),2);
count2=zeros(length(candidate),1);
idx=cell(length(candidate),1);
th=zeros(length(candidate),1);
discard=zeros(length(candidate),1);
for i=1:length(candidate)
    
    
    env=envelope(candidate{i}(:,2),fs)';
    env_back=envelope(candidate{i}([1:round(ld/3-1) round(2*ld/3)+1:end],2),fs);
    %env_back=envelope(candidate{i}([1:round(ld/4-1) round(3*ld/4)+1:end],2),fs);
    th(i)=3*median(env_back);
    FF_mid=find(env>th(i));%see the envelope in the middle
    FF_mid2=find(env>20*th(i));
    
    count=zerocross_count(detrend(candidate{i}(:,1),'constant')');%%%%%%%%%%%%%zero crossing of the raw
    [count2(i,1),idx{i,1}]=zerocross_count((candidate{i}(:,2)-th(i))');
    %dat=data_norm(candidate{i}(:,1),2);
    %tft=stft(filtfilt(b,a,dat),256*round(fs/1000),fs,hanning(round(64*(fs/1000))),4,0);
    
    
    
    %diff(idx{i})>0.05*fs
    %[bb,aa]=butter(2,8/(fs/2),'high');
    %sig=filtfilt(bb,aa,candidate{i}(:,1));
    %count3=zerocross_count(sig');
    if op==1% keep everything
        %if isempty(FF_mid)|| ~isempty(FF_mid2) || count2(i,1)<8 || count>=10
        if  count2(i,1)<8 || count>=10
            discard(i)=1;
            continue;
        else
            %             y=detrend(candidate{i}(:,1),'constant');
            %             Y(:,xx)=y./sqrt(sum(y.^2));
            %             [tf_temp,~,f]=stft(filtfilt(b,a,Y(:,xx)),2048*round(fs/1000),fs,hanning(64)*round(fs/1000),1,0);
            %             tl=round(size(tf_temp,2)/3);
            %             tf(:,:,xx)=tf_temp(:,tl:2*tl);
            %             tf_denoised(:,:,xx)=denoise(tf(:,:,xx),[0.98 0]);
            %             [dif,idp(xx,1)]=peak_notch(tf(:,:,xx),tf_denoised(:,:,xx),fs);
            y=detrend(candidate{i}(:,1),'constant');
            Y(:,xx)=y./sqrt(sum(y.^2));
            [tf_temp{xx},~,f]=stft(filtfilt(b,a,Y(:,xx)),2048*round(fs/1000),fs,hanning(round(64*(fs/1000))),1,0);
            tl=round(size(tf_temp{xx},2)/3);
            tf(:,:,xx)=tf_temp{xx}(:,tl:2*tl);
            tf_denoised(:,:,xx)=denoise(tf(:,:,xx),[dn 0]);
            

            
            tt=tf(:,:,xx);
            pt=mean(tt')';
            p1=round((length(pt)*50)/(fs/2))+1;
            p2=round(length(pt)*100/(fs/2))+1;
            nt=find(pt(p1:p2)==min(pt(p1:p2)))+p1-1;
            [dif,idp(xx,1)]=peak_notch(tf(:,:,xx),tf_denoised(:,:,xx),fs,nt,p1);
            %             if dif==1
            %                 discard(i)=1;
            %                 continue;
            %             else
            Y2=filtfilt(b,a,candidate{i}(:,1));
            %Y2=filtfilt(b,a,y);
            %Y2=Y2./sqrt(sum(Y2.^2));
            Y2=Y2(round(ld/3):round(2*ld/3));
            [PXX(:,xx),R]=pwelch(Y2,hanning(round(64*(fs/1000))),round(48*(fs/1000)),round(256*(fs/1000)),fs);
            differ(xx,1)=max(abs(candidate{i}(:,2)))-th(i);
            
        end
        %            xx=xx+1;
        %             Y2=filtfilt(b,a,y);
        %             Y2=Y2./sqrt(sum(Y2.^2));
        %             Y2=Y2(round(ld/3):round(2*ld/3));
        %             [PXX(:,xx),R]=pwelch(Y2,hanning(64)*round(fs/1000),48,256*round(fs/1000),1024);
        %             differ(xx,1)=max(abs(candidate{i}(:,2)))-th(i);
        %             xx=xx+1;
        %              end
        
    elseif op==0% eliminate noise
        
         %if isempty(FF_mid)|| ~isempty(FF_mid2) || count2(i,1)<=4 || count>=14 ||idx{i}(1) < (ld/2-80*(fs/1000)) || idx{i}(end) > (ld/2+80*(fs/1000))   %60 initially
         if isempty(FF_mid)|| ~isempty(FF_mid2) || count2(i,1)<=2 || count>=14 ||idx{i}(1) < (ld/2-80*(fs/1000)) || idx{i}(end) > (ld/2+80*(fs/1000))   
            discard(i)=1;
             continue;
          elseif  length(FF_mid)<20*(fs/1000) || length(FF_mid)>100*(fs/1000)  %20, 100
             discard(i)=1;
            continue;
           
           
%          elseif std(candidate{i}(:,1))>=0.2
%            discard(i)=1;
%            continue;
         else
            y=detrend(candidate{i}(:,1),'constant');
            Y(:,xx)=y./sqrt(sum(y.^2));
            [tf_temp{xx},~,f]=stft(filtfilt(b,a,Y(:,xx)),1024*round(fs/1000),fs,hanning(round(64*(fs/1000))),1,0);%2048 initial
            %tf_temp{xx} = norm_tf(tf_temp{xx},16:200:floor(fs/2),fs);
            
% to eleminate some artifact     
%             y=y./norm(y,2);
%             [tft,~,~]=stft(filtfilt(b,a,y),256*round(fs/1000),fs,64*round(fs/1000),2,0);%%%should be 64*round(fs/1000)
%             if sum(tft(:))<800
%                 discard(i)=1;
%                 continue;
%             end
            
            
            
            
            tl=round(size(tf_temp{xx},2)/3);
            tf(:,:,xx)=tf_temp{xx}(:,tl:2*tl);
            
            tt=tf(:,:,xx);
            pt=mean(tt')';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%             ttd=denoise(tt,[0.9,0]);
%             ptd=mean(ttd')';
%             pf=find(ptd==eps);
%             pf=pf(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            p1=round(length(pt)*50/(fs/2));
            p2=round(length(pt)*100/(fs/2));
            nt=find(pt(p1:p2)==min(pt(p1:p2)))+p1-1;

            
            %tf_denoised(:,:,xx)=tt;
            %tf_denoised(nt:end,:,xx)=denoise(tt(nt:end,:),[0.3 0]);
            
            
            %[dif,idp(xx,1)]=peak_notch(tf(:,:,xx),tf_denoised(:,:,xx),fs,nt,p1);
            %[factor(xx,1),idp(xx,1)]=pn_factor(tt,tf_denoised(:,:,xx),fs,nt,p1);
            
            tf_denoised(:,:,xx)=denoise(tf(:,:,xx),[dn 0]);
            %tf_denoised(:,:,xx)=denoise2(tf(:,:,xx),dn3);
            [dif,idp(xx,1)]=peak_notch(data_norm(tf(:,:,xx),5),tf_denoised(:,:,xx),fs,nt,p1);
            
%               if dif==1
%                   discard(i)=1;clc
%                   continue;
%                else
                %Y2=filtfilt(b,a,Y(:,xx));
                Y2=filtfilt(b,a,candidate{i}(:,1));
                %Y2=filtfilt(b,a,y);
                %Y2=Y2./sqrt(sum(Y2.^2));
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                %Y2=Y2(round(ld/3):round(2*ld/3));
                [PXX(:,xx),R]=pwelch(Y2,hanning(round(64*(fs/1000))),round(48*(fs/1000)),round(256*(fs/1000)),fs);
                differ(xx,1)=max(abs(candidate{i}(:,2)))-th(i);
                
%             end
            xx=xx+1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dis=candidate(logical(discard));


th(logical(discard))=[];       %
G_coef(logical(discard),:)=[]; %
candidate(logical(discard))=[];%
idx(logical(discard))=[];%
hl=zeros(length(candidate),1);
hf=zeros(length(candidate),1);
Dist=zeros(length(candidate),1);
cc=zeros(length(candidate),1);
center_total=zeros(length(candidate),1);
ttE=zeros(length(candidate),1);
ent=zeros(length(candidate),1);
ra_old=zeros(length(candidate),1);
ra_no_denoise=zeros(length(candidate),1);
x=round((length(candidate)/24))+1;

for i=1:length(candidate)
  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %1: Sub-band Power Ratio%%%%%
    %p1=sum(tf(:,:,i)');
    p1=sum(tf_temp{i}');
    p2=sum(tf_denoised(:,:,i)');
    
    %bp1=bandpower(sqrt(PXX(:,i)),[1 80],fs);
    %bp2=bandpower(sqrt(PXX(:,i)),[80 450],fs);
    bp3=bandpower(sqrt(PXX(:,i)),[1 fc],fs);
    
    bp1=bandpower(sqrt(p1'),[1 80],fs);
    bp2=bandpower(sqrt(p1'),[80 fc],fs);
    
    hl(i,1)= (bp2/bp1);
    %hf(i,1)=(bp2/bp3);
    
    
     %hl(i,1)= (bp1-bp2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %2: Entropy%%%%%%%%%%%%%%%%%%%
    
    [~,~,~,ENT,~,~]=ENG(Y(:,i),tf_temp{i},f,fs,dn);
    %center_total(i,1)=ctr_ttl_rate_h;
    %ttE(i,1)=tt_E;
    ent(i,1)=ENT;
    %[fp,gap]=find_peak(PXX(:,i));
    %ra_no_denoise(i,1)=fp/gap;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    low_tf(i)=mean(tf_temp{i}(1,:));%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if compare==1
        
        %%%%%%%%%%%%%%%%%%for feature comparison%%%%%%%%%%%%%%%%%%%%%%%%
        bp4=bandpower(sqrt(PXX(:,i)),[100 250],fs);
        bp5=bandpower(sqrt(PXX(:,i)),[250 500],fs);
        fr_r(i,1)= (bp5/bp4);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         bp1=bandpower(sqrt(p2),[1 80],fs);
        %         bp2=bandpower(sqrt(p2),[80 fc],fs);
        %         bp3=bandpower(sqrt(p2),[1 fc],fs);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Peak to Notch Ratio%%%%%%
        %ra_old(i,1)=find_peak2(PXX(:,i),fs);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Line Length%%%%%%%%%%%%%%%
        dy=diff(Y(:,i));
        L=sum(abs(dy));
        dias=zeros(1,ld);
        for dd=1:ld
            dias(dd)=sqrt(dd^2+Y(dd)^2);
        end
        d=max(dias);
        Dist(i,1)=log10(ld)/(log10(d/L)+log10(ld));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %4: Spectra Centroid%%%%%%%%%%%
        [PXX2,R]=pwelch(candidate{i}(:,2),hanning(64*round(fs/1000)),48*round(fs/1000),256*round(fs/1000),fs);
        R(1)=eps;
        cc(i,1)=sum(R.*PXX2./sum(PXX2));
        %f3(i,1)=R(find(max(log10(PXX(:,i)))));
        
        B = 1/3*ones(3,1);
        s = filter(B,1,candidate{i}(:,2));
        [pks,locs] = findpeaks(s);
        g_pk=max(pks);
        pks(find(max(pks)))=[];
        g_avl(i,1)=g_pk/mean(pks);
        [ey,ex]=energyop(candidate{i}(:,2),0);
        ex=ex.^2;
        exn=ex./sum(ex);
        entropy(i,1)=wentropy(exn,'shannon');
    else
        continue;
    end
    %cc(i,1)=sum(R.*PXX(:,i))./sum(PXX(:,i));
    
    
end

if length(idp)~=length(hl)
    idp(end)=[];
    Y(:,end)=[];
end

if compare==1
    [inspk] = wave_features(Y');
    COEFF = pca(inspk');
    wav = COEFF(:,1);
    set=[fr_r,Dist,cc,g_avl,entropy,wav];
    PCA = pca(set');
    PCA=PCA(:,1:4);
else
    PCA=zeros(length(candidate),4);
    entropy=zeros(length(candidate),1);
    ttE=zeros(length(candidate),1);
end
% set2=[hl,idp,log(ent),cc];
% PCA2 = pca(set2');
% PCA2=PCA2(:,1:3);



%E_TOTAL=[(hl),log(idp),PCA,low_tf',ttE,log(ent)];



E_TOTAL=[log(hl),log(idp),PCA,entropy,ttE,log(ent)];
%E_TOTAL=[sqrt(factor),log(idp),PCA,entropy,ttE,log(ent)];




%E_TOTAL=[PCA2(:,1),PCA2(:,2),PCA,entropy,ttE,PCA2(:,3)];



%E_TOTAL=[hl,sqrt(idp),Dist,cc,ra_old,g_avl,entropy,ttE,sqrt(ent)];
feature_matrix=data_norm(E_TOTAL,5);% feature matrix is for manual clustering
%[~,projection,~] = princomp(feature_matrix);% projection is for auto clustering
projection=feature_matrix;
cla;
%set(gca,'visible','off');
Feature{1}='Sub-band Power Ratio ([80 500]/low)';%changed
Feature{2}='Frequency with max P/N';%changed
Feature{3}='Line Length';
Feature{4}='Spectral Centroid';%changed
Feature{5}='Peak to notch Ratio (OLD)';
Feature{6}='Global/avg-local max Ratio';%changed
Feature{7}='Entropy of Teager Energy';%fixed to 80
Feature{8}='Maximum Energy in Low Band';
Feature{9}='Entropy';% changed
end
