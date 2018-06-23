function [V,mgridfilenames,leptoCoor,surfpath] = get_images(meeg)
V = [];
mgridfilenames = [];
leptoCoor = [];
surfpath = [];
try
sbjpath = path(meeg);
sublist = strsplit(genpath(sbjpath),':')';
n = 1;
elecpath = find(contains(sublist,'elec_recon'));
while isempty(elecpath)
    %if isempty(elecpath)
        [upper,~] = fileparts(sbjpath);
        sbjpath = upper;
        sublist = strsplit(genpath(upper),':')';
        elecpath = find(contains(sublist,'elec_recon'));
        if length(elecpath) >3 || n > 3
            elecpath = [];
            sbjpath = path(meeg);
            break;
        end
        n = n+1;
    %end
end

if isempty(elecpath) 
        fprintf('------Please select the subject Freesurfer folder -------\n')
        selpath = uigetdir;
        if isempty(selpath)
            V = [];
            mgridfilenames = [];
            leptoCoor = [];
            return;
        end
        [upper,curr] = fileparts(selpath);
        if contains(lower(selpath),'jparvizi')
            serverpath = selpath;
            fprintf('----------Copying files from the server ------------\n')
            elecfolder = fullfile(serverpath,'elec_recon');
            mkdir(fullfile(sbjpath,'elec_recon'));
            [~,~] = copyfile(elecfolder,fullfile(sbjpath,'elec_recon'));
            elecpath = fullfile(sbjpath,'elec_recon');
            [~,~] = copyfile(fullfile(serverpath,'surf','lh.pial'),elecpath);
            [~,~] = copyfile(fullfile(serverpath,'surf','rh.pial'),elecpath);
            fprintf('---------------  Finished  ---------------\n')
        elseif strcmpi(curr,'elec_recon')
            sbjpath = upper;
            elecpath = selpath;
        else
            sbjpath = selpath;
            elecpath = fullfile(sbjpath,'elec_recon');
        end
else
    elecpath = sublist{elecpath(1)};
end
mriFname = fullfile(elecpath,'brainmask.nii');
try
    V = spm_read_vols(spm_vol(mriFname));
catch
        gunzip(fullfile(elecpath,'brainmask.nii.gz'));
        V = spm_read_vols(spm_vol(mriFname));
end
[upper,~] = fileparts(elecpath);
sublist = strsplit(genpath(upper),':')';
surfpath = find(contains(sublist,{'/surf','\surf'}));
if isempty(surfpath)
    surfpath = elecpath;
else
    surfpath = sublist{surfpath(1)};
end
sbjnames = dir(fullfile(elecpath, '*.INF'));
try
    sbjnames = fullfile(sbjnames.folder,sbjnames.name);
    [~,nm,~] = fileparts(sbjnames);
    nm1 = strcat(nm, '.mgrid');
    mgridfilenames = fullfile(elecpath,nm1);
    nm2 = strcat(nm, '.LEPTO.txt');
    LEPTOfilenames = fullfile(elecpath,nm2);
    if ~exist(LEPTOfilenames,'file')
        nm3 = strcat(nm, '.LEPTO');
        leptoold = fullfile(elecpath,nm3);
        movefile(leptoold, LEPTOfilenames);
    end
    leptoCoor = importdata(LEPTOfilenames);
    leptoCoor = leptoCoor.data;
catch
   
    sbjnames = dir(fullfile(elecpath, '*.mgrid'));
    if length(sbjnames)==1
        sbjnames = fullfile(sbjnames.folder,sbjnames.name);
        [~,nm,~] = fileparts(sbjnames);
        mgridfilenames = sbjnames;
    elseif length(sbjnames)>1
        mgridfilenames = {sbjnames.name};
        ln = zeros(length(mgridfilenames),1);
        for k=1:length(mgridfilenames)
            ln(k) = length(char(mgridfilenames(k)));
        end
        tk = ln == min(ln);
        mgridfiles = sbjnames(tk);
        mgridfilenames = fullfile(mgridfiles.folder,mgridfiles.name);
        [~,nm,~] = fileparts(mgridfilenames);
    else
        mgridfilenames = [];
    end
    try
        nm2 = strcat(nm, '.LEPTO.txt');
        LEPTOfilenames = fullfile(elecpath,nm2);
        if ~exist(LEPTOfilenames,'file')
            nm3 = strcat(nm, '.LEPTO');
            leptoold = fullfile(elecpath,nm3);
            movefile(leptoold, LEPTOfilenames);
        end
        leptoCoor = importdata(LEPTOfilenames);
        leptoCoor = leptoCoor.data;
    catch
    end  
end
catch
    disp('Can not load image. Continue ...');
end
