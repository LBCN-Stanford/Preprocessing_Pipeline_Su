function script_launch_multiple_sessions_convertTDT(nsess)

files = cell(nsess,1);
for i=1:nsess
    files{i} = spm_select;
end

for i=1:nsess
    [D] = Convert_TDTiEEG_to_SPMfa('TDT',files{i},1);
end