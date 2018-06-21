function skip_before = find_skip(diod, thresh_dur, samp_rate)
%   If the default skip pulses are incorrect, find the right number.
%   -----------------------------------------
%   =^._.^=     Su Liu
%
%   suliu@standord.edu
%   -----------------------------------------


diod = diod/max(diod);
tmp = zeros(length(diod),1);
tmp(diod>0.3) = 1;

xx = diff(tmp);
onsets = find(xx==1); %onsets, no filtering
offsets = find(xx==-1);
dur = offsets - onsets;
ind = dur>=thresh_dur*samp_rate;
onsets= onsets(ind);
if length(onsets) ~= length(offsets)
    if onsets(end) < offsets(end)
        onsets(end) = [];
    elseif onsets(1) < offsets(1)
        offsets(1) = [];
    end
end
onn = diff(onsets);

before = find(onn<0.5*median(onn));
try
    skip_before = before(end)+1;
    if skip_before >20
        skip_before = 0;
    end
catch
    skip_before = 0;
end
