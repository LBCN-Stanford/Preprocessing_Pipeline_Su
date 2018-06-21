function data_meeg_f = notch_meeg(data_meeg,f0,harmonics)

if nargin<1 || isempty(data_meeg)
    [filename,pathname] = uigetfile({'*.mat','Data format (*.mat)'},...
        'MultiSelect', 'on');
    data_meeg = fullfile(pathname,filename);
end
if nargin<2 || isempty(f0)
    f0 = 60;
end
if nargin<3 || isempty(harmonics)
    harmonics = 4;
end

N = size(data_meeg,1);
data_meeg_f = cell(N,1);
for n = 1:N
    try
        load(data_meeg(N,:));
    catch
        D = data_meeg{n};
    end
    data = D.data(:,:,:)';
    [b,a]=butter(2,[1 200]/(D.Fsample/2));
    for i = 1:harmonics
        f = f0*i;
        data = notch_manual(data,D.Fsample,f);
    end
    data=filtfilt(b,a,data);
    D.data(:,:) = data';
    
    D = meeg(D);
    data_meeg_f{n} = D;
end

