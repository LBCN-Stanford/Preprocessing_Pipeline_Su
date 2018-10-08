
fn = fieldnames(K);
content = getfield(K,fn{1});
if istable(content)
    evt.onsets = content.StimulusOnsetTime;
    evt.offsets = content.StimulusEndTime;
    SOT = [content.StimulusOnsetTime;content.StimulusOnsetTime(end)];
    evt.durations = evt.onsets - evt.offsets;
    [a,b,c]=unique(content.condNames);
    K.conds = c;
    deftask.listcond = a;
    sbj_resp = nan(size(c));
end
    