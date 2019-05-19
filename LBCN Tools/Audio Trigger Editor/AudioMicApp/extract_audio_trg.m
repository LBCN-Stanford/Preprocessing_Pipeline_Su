function [Triggerd]=extract_audio_trg(trigger,fs,param, int)
if nargin < 3
    param = 0.3;
end
if nargin < 4
    int = 0.3;
end
interv = int * fs;
trg=envelope(trigger);
trg=data_norm(trg);
trg(trg<0.8)=0; % 0.75 was identified manually from data by visual inspection
rTriggerData = round(trg*param);

dTriggerData = [0;find(rTriggerData(1:end-1)~=rTriggerData(2:end))]+1;
d1=find(diff(dTriggerData)<50)+1;
dTriggerData([1;d1]) = [];
sectionCodes = [dTriggerData(1:end-1) dTriggerData(2:end)-1 rTriggerData(dTriggerData(1:end-1))];
Trigger=sectionCodes;
%RisingIdx=sectionCodes((sectionCodes(:,3)==min(Trigger(:,3))),1);
%FallingIdx=sectionCodes((sectionCodes(:,3)==max(Trigger(:,3))),1);

edge=nan(1,length(trigger));
Triggerd = Trigger(2:end,1);

Triggerd(diff(Trigger(:,1)) < interv) = [];
%RisingIdx=sectionCodes((sectionCodes(:,3)==min(Trigger(:,3))),1);
%FallingIdx=sectionCodes((sectionCodes(:,3)==max(Trigger(:,3))),1);

% for i = Triggerd(:,1)'
%     edge(i) = 0;
% end
% plot(trigger);hold on;plot(edge,'r.');
 end

%TriggerStartIndex = find(sectionCodes(:,3) == 1);


