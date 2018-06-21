function [yl1, yl2] = get_ylim(signal_all , chanlabels,b,t)
cn = length(chanlabels);
Nt = length(signal_all);
ign = 100;
same_group = zeros(1,cn);
sig_samegroup_avg = [];
sig_samegroup_avgAll = [];
groupName = [];
groupNo = 1;
cnn = 1;
yl1 = [];
yl2 = [];
for i = 2:cn
    name1 = join(regexp(string(chanlabels{i-1}),'[a-z]','Match','ignorecase'),'');
    name2 = join(regexp(string(chanlabels{i}),'[a-z]','Match','ignorecase'),'');
    if strcmp(name1,name2)
        same_group(i) = 1;
        cnn = cnn+1;
        for j = 1:Nt
            try
                sig_samegroup_avg(:, j) = nanmedian((signal_all{j}{i}(ign:(end-ign),:)),2);
            catch
                sig_samegroup_avg(:,j) = nan;
            end
        end
       sig_samegroup_avgAll = [sig_samegroup_avgAll (sig_samegroup_avg)];
    else
        groupName{groupNo} = name2;
        y1 = min(sig_samegroup_avgAll(:))*b;
        y2 = max(sig_samegroup_avgAll(:))*t;
        yl1 = [yl1 y1*ones(1,cnn)];
        yl2 = [yl2 y2*ones(1,cnn)];
        cnn=1;
        groupNo = groupNo + 1;
        for j = 1:Nt
            try
                sig_samegroup_avg(:,j) = nanmedian((signal_all{j}{i}(ign:(end-ign),:)),2);
            catch
                 sig_samegroup_avg(:,j) = nan;
            end
        end
        sig_samegroup_avgAll = nanmedian(sig_samegroup_avg,2);
    end
end
if any(isnan(yl1))
    yl1(isnan(yl1)) = nanmean(yl1);
    yl2(isnan(yl2)) = nanmean(yl2);
end