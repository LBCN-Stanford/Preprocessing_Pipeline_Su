function [new_sig] = format_signal(sig_mat, sig_header,plot_cond,exclude)
if isempty(sig_mat)
for i = 1:length(sig_header)
    sig_mat{i} = sig_header{i}(:,:,:);
end
end
if isempty(plot_cond)
    plot_cond = 1 : nconditions(sig_header{1});
end
new_sig = arrange(sig_mat, [], sig_header, plot_cond, exclude);