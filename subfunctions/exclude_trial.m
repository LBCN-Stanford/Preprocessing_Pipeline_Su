function [exclude,exclude_ts] = exclude_trial(pTS,pChan,onsetTS,chanNames,twepoch,bad)
%   Finds trials with pathological events. For each pathological event,
%   finds the [pTS - 50 ~ pTS + 50] samples, and detects whether
%   it overlaps with any trial epoch .
%   Output:     exclude : {channel index}([trial index;timestamps;corrupted or not])
%               exclude_ts:timestamps of the event.  
%   Input:      pTS:       timestamps of pathological events.
%               pChan:     corresponding channels (in bipolar).
%               onsetTS:   timestamps of behavioral onset. Single vector.
%               chanNames: channel lables. Names and channel order should match
%               the labels in "pChan".
%               twepoch:   epoched window. Default [- 300 ~ 800].
%   -----------------------------------------   
%   =^._.^=    Su Liu 
%
%   suliu@standord.edu
%   -----------------------------------------

if nargin<5
    twepoch = [-300 800];
end
if nargin<6
    bad = false(length(pChan));
end

chan=cell(length(pChan),2);

for i = 1:length(pChan)
    try
        chan(i,:) = strsplit(pChan{i},'-');
    catch
        temp=strsplit(pChan{i},'-');
        if length(temp)==4
            chan(i,1)=strcat(temp(1),'-',temp(2));
            chan(i,2)=strcat(temp(3),'-',temp(4));
        else
            error('Channel name mismatch');
        end
    end
end
exclude = cell(1,length(chanNames));
exclude_ts = zeros(length(chanNames),(twepoch(2) - twepoch(1)+1),length(onsetTS));
for i = 1:length(chanNames)
    n = 1;
    T = length(onsetTS);
    ind = unique([find(strcmp(chan(:,1),chanNames(i)) == 1 );find(strcmp(chan(:,2),chanNames(i)) == 1 )]);
    target = pTS(ind);
    pind = [target-50 target+50];
    pindc = [];
    if ~isempty(target)
        for l = 1:length(target)
            pindc = [pindc pind(l,1):pind(l,2)];
        end
    end
    for k = 1:T
        behInd = onsetTS(k) + twepoch(1) : onsetTS(k) + twepoch(2);
        if sum(ismember(pindc,behInd)) ~= 0
            exclude{i}(1,n) = k;
            tind = find(ismember(behInd,target));
            if ~isempty(tind)
                exclude{i}(2,n) = any(bad(ind(ismember(target,behInd))));
            else 
                tind = find(pindc(ismember(pindc,behInd)));
                exclude{i}(2,n) = 0;
            end
            exclude_ts(i,tind,k) = 1;
            n = n+1;
        end
    end
end

