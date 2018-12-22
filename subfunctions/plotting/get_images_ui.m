function [V,mgridfilenames,leptoCoor,surfpath,elecpath] = get_images_ui(sd,figurehandle,infohandle, elecpath)
V = [];
mgridfilenames = [];
leptoCoor = [];
surfpath = [];
if nargin <4
    elecpath = [];
end
try
    if isempty(elecpath)
        sbjpath = path(sd);
        sublist = strsplit(genpath(sbjpath),':')';
        n = 1;
        elecpath = find(contains(sublist,'elec_recon'));
        while isempty(elecpath) && n < 3
            [upper,~] = fileparts(sbjpath);
            sbjpath = upper;
            sublist = strsplit(genpath(sbjpath),':')';
            if numel(sublist)>20
                break;
            end
            elecpath = find(contains(sublist,'elec_recon'));
            if numel(elecpath) >3
                elecpath = [];
                sbjpath = path(sd);
                break;
            elseif numel(elecpath) == 1 || numel(elecpath) ==2
                elecpath = elecpath(1);
                break;
            end
            n = n+1;
        end
        
        if isempty(elecpath)
            figurehandle.Visible = 'off';
            figurehandle.Visible = 'on';
            infohandle.Text = sprintf('\nPlease select the image directory \n\n(From server: folder with sbj name; \n\nFrom local: folder "elec_recon") ');
            infohandle.HorizontalAlignment = 'right';
            pause(0.1);
            selpath = uigetdir;
            if isempty(selpath)
                V = [];
                mgridfilenames = [];
                leptoCoor = [];
                return;
            end
            [~,curr] = fileparts(selpath);
            if contains(lower(selpath),'jparvizi')
                serverpath = selpath;
                infohandle.Text = sprintf('Copying files from the server  \n');
                pause(0.2);
                elecfolder = fullfile(serverpath,'elec_recon');
                [upper,~] = fileparts(path(sd));mkdir(fullfile(upper,'elec_recon'));
                [~,~] = copyfile(elecfolder,fullfile(upper,'elec_recon'));
                elecpath = fullfile(upper,'elec_recon');
                [~,~] = copyfile(fullfile(serverpath,'surf','lh.pial'),elecpath);
                [~,~] = copyfile(fullfile(serverpath,'surf','rh.pial'),elecpath);
                infohandle.Text = sprintf('Finished. \n');
                pause(0.2);
            elseif strcmpi(curr,'elec_recon')
                %sbjpath = upper;
                elecpath = selpath;
            else
                sbjpath = selpath;
                elecpath = fullfile(sbjpath,'elec_recon');
            end
        else
            elecpath = sublist{elecpath(1)};
        end
    end
    %%%%%%%%%%%
    infohandle.Text = sprintf('Loading image... \n');
    figurehandle.Visible = 'off';
    figurehandle.Visible = 'on';
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
    infohandle.Text = sprintf('Can not load image. Continue ... \n');
    pause(0.2);
end
