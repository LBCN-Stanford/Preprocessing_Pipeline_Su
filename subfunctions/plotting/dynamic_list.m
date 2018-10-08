%dynamic_list;
currentfolder = pwd;
cd(fileparts(which('get_defaults_Parvizi.m')));
def = get_defaults_Parvizi;
%get_defaults_Parvizi;
confn = fieldnames(def);
for i = 23:length(confn)
    tasklist{i-22} = confn{i};
end
cd(currentfolder);
