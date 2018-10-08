function [onsetDiff,SOT0, SOT, rsp_onset, stim_onset,stim_onset0, stim_dur,skipbefore_beh, skipafter_beh] = force_match(evt, SOT0)
n1 = length(evt.onsets);
n2 = length(SOT0);
skipbefore_beh = [];
skipafter_beh = [];
info = sprintf('Diod onset No.: %d; Behav onset No.: %d. Would you like to force continue?',n1,n2);
answer = questdlg(info, ...
    'Options', ...
    'Ignore', 'Recording started late?','Recording ended early?','Ignore');
% Handle response
switch answer
    case 'Ignore'
        %         if n1-n2 > -2 || SOT0(end) - (evt.onsets(end)-evt.onsets(1)) < 10
        %             stim_onset = [evt(:).onsets];
        %             rsp_onset= [evt(:).offsets];
        %             stim_dur = [evt(:).durations];
        %             stim_onset0 = stim_onset-stim_onset(1);
        %             ini = evt(1).onsets(1);
        %SOT = evt.onsets;
        %             SOT0 = evt.onsets-ini;
        %             SOT = evt.onsets;
        %
        %         else
        ini = evt(1).onsets(1);
        for i = 1:length(SOT0)
            try
                evt(i).onsets = SOT0(i)+ini;
                evt(i).offsets = evt(i).onsets + 0.02;
                evt(i).durations = 0.02;
            catch
                continue;
            end
        end
        stim_onset = [evt(:).onsets];
        rsp_onset= [evt(:).offsets];
        stim_dur = [evt(:).durations];
        stim_onset0 = stim_onset-stim_onset(1);
        SOT = SOT0 + ini;
        %        end
        
        %     case 'Quit'
        %         onsetDiff = [];
        %         SOT = [];
        %         rsp_onset = [];
        %         stim_onset = [];
        %         stim_onset0 = [];
        %         stim_dur = [];
    case 'Recording started late?'%skip some behavioral data
        skipbefore_beh = 1:abs(n1-n2);
                stim_onset = [evt(:).onsets];
                rsp_onset= [evt(:).offsets];
                stim_dur = [evt(:).durations];
                stim_onset0 = stim_onset-stim_onset(1);
                ini = evt(1).onsets(1);
                SOT0 = evt.onsets-ini;
                SOT = evt.onsets;
        
%         ini = evt(1).onsets(1);
%         for i = 1:length(SOT0)
%             try
%                 evt(i).onsets = SOT0(i)+ini;
%                 evt(i).offsets = evt(i).onsets + 0.02;
%                 evt(i).durations = 0.02;
%             catch
%                 continue;
%             end
%         end
%         stim_onset = [evt(:).onsets];
%         rsp_onset= [evt(:).offsets];
%         stim_dur = [evt(:).durations];
%         stim_onset0 = stim_onset-stim_onset(1);
%         SOT = SOT0 + ini;
    case 'Recording ended early?'
        skipafter_beh = n1+1:n2;
                stim_onset = [evt(:).onsets];
                rsp_onset= [evt(:).offsets];
                stim_dur = [evt(:).durations];
                stim_onset0 = stim_onset-stim_onset(1);
                ini = evt(1).onsets(1);
                SOT0 = evt.onsets-ini;
                SOT = evt.onsets;
        
%         ini = evt(1).onsets(1);
%         for i = 1:length(SOT0)
%             try
%                 evt(i).onsets = SOT0(i)+ini;
%                 evt(i).offsets = evt(i).onsets + 0.02;
%                 evt(i).durations = 0.02;
%             catch
%                 continue;
%             end
%         end
%         stim_onset = [evt(:).onsets];
%         rsp_onset= [evt(:).offsets];
%         stim_dur = [evt(:).durations];
%         stim_onset0 = stim_onset-stim_onset(1);
%         SOT = SOT0 + ini;
end
onsetDiff = SOT0-[stim_onset0 zeros(1,length(SOT0)-length(stim_onset0))];