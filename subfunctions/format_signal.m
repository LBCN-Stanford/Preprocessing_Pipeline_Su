function [new_sig] = format_signal(sig_mat, sig_header,plot_cond,exclude,labels,conditionList)
if isempty(sig_mat)
    for i = 1:length(sig_header)
        sig_mat{i} = sig_header{i}(:,:,:);
    end
end
if isempty(plot_cond)
    plot_cond = 1 : nconditions(sig_header{1});
end
if nargin < 5 || isempty(labels)
    labels = [];
end
if nargin < 6 || isempty(conditionList)
    conditionList = [];
end
new_sig = arrange(sig_mat, [], sig_header, plot_cond, exclude,labels,conditionList);