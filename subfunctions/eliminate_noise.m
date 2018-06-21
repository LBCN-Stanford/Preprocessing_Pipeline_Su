function [discard] = eliminate_noise(data,fs)
%   Eliminate noise after initial detection
%   Su Liu
candidate = cell(1,size(data,3));
pre = 127*(fs/1000);
post = 128*(fs/1000);
ind = round(size(data,1)/2-pre):round(size(data,1)/2+post);
ld = length(ind);
for i = 1:size(data,3)
    candidate{i}(:,1) = data(ind,1,i);
    candidate{i}(:,2) = data(ind,2,i);
    candidate{i}(:,3) = i;
end
count2 = zeros(length(candidate),1);
idx = cell(length(candidate),1);
th = zeros(length(candidate),1);
discard{1} = zeros(length(candidate),1);
discard{2} = zeros(length(candidate),1);
for i = 1:length(candidate)
    env = envelope(abs(candidate{i}(:,2)),fs)';
    env_back = envelope(abs(candidate{i}([1:round(ld/3-1) round(2*ld/3)+1:end],2)),fs);
    th(i) = 3*median(env_back);
    FF_mid = find(env>th(i));
    FF_mid2 = find(env>20*th(i), 1);
    %count = zerocross_count(detrend(candidate{i}(:,1),'constant')');%zero crossing of the raw
    [count2(i,1),idx{i,1}] = zerocross_count((candidate{i}(:,2)-th(i))');
         if ~isempty(FF_mid2)
             discard{2}(i)=1;
         elseif isempty(FF_mid)|| count2(i,1)<=2 ||...%count>=10 ||
                 idx{i}(1) < (ld/2-80*(fs/1000)) ||...
                 idx{i}(end) > (ld/2+80*(fs/1000)) 
            discard{1}(i)=1;
            
             continue;
         %elseif  length(FF_mid)<20*(fs/1000) || length(FF_mid)>100*(fs/1000)
         %   discard(i)=1;
         %  continue;
         end
end