
fid=fopen('mytask.m');
cac = textscan( fid, '%s', 'Delimiter','\n', 'CollectOutput',true );
fclose( fid );
fid=fopen('mytaskP.m');
cac3 = textscan( fid, '%s', 'Delimiter','\n', 'CollectOutput',true );
fclose( fid );
fid=fopen('newTaskCond.m');
cac5 = textscan( fid, '%s', 'Delimiter','\n', 'CollectOutput',true );
fclose( fid );

cd(fileparts(which('HFB plot/subfunctions/task_config.m')));
fid=fopen('task_config.m');
cac2 = textscan( fid, '%s', 'Delimiter','\n', 'CollectOutput',true );
fclose( fid );

cd(fileparts(which('LBCN_read_events_diod_sodata.m')));
fid=fopen('LBCN_read_events_diod_sodata.m');
cac4 = textscan( fid, '%s', 'Delimiter','\n', 'CollectOutput',true );
fclose( fid );


for jj = 1:length(cac2{1})
    if strcmp(cac2{1}{jj},'confn = fieldnames(p);')
        n=jj-5;
        break;
    end
end
for jj = 1:length(cac4{1})
    if strcmp(cac4{1}{jj},'%% Take out events with a NaN as start')
        n2=jj-4;
        break;
    end
end

%% Rewrite task_config
cd(fileparts(which('HFB plot/subfunctions/task_config.m')));
fid=fopen('task_config.m','w');

for jj = 1 : n
    fprintf( fid, '%s\n', cac2{1}{jj} );
end

ss = strsplit(cac{1}{7},'=');
tn = ss{2}(1:end-1);

fprintf(fid,'case ');fprintf(fid,tn);

for jj = 8:length(cac{1})
    
    fprintf( fid, '%s\n', cac{1}{jj} );
end


for jj = n+1 : length(cac2{1})
    fprintf( fid, '%s\n', cac2{1}{jj} );
end
fclose( fid );

%% Rewrite LBCN_read_events_diod_sodata
cd(fileparts(which('LBCN_read_events_diod_sodata.m')));
fid=fopen('LBCN_read_events_diod_sodata.m','w');

for jj = 1 : n2
    fprintf( fid, '%s\n', cac4{1}{jj} );
end

fprintf(fid,'case ');fprintf(fid,tn);

for jj = 1:length(cac5{1})
    
    fprintf( fid, '%s\n', cac5{1}{jj} );
end


for jj = n2+1 : length(cac4{1})
    fprintf( fid, '%s\n', cac4{1}{jj} );
end
fclose( fid );





%% Append get_defaults_Parvizi
cd(fileparts(which('get_defaults_Parvizi.m')));
fid=fopen('get_defaults_Parvizi.m','a+');
for jj = 9 : length(cac3{1})
    fprintf( fid, '%s\n', cac3{1}{jj} );
end
fclose( fid );

