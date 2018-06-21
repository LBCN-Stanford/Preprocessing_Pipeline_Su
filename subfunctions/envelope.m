function envmax=envelope(sig,fs,param)
% Generates the envelope of the signal.
% Written by Su Liu.
% suliu@stanford.edu
if nargin<3
    param=8;
end
env=real(hilbert(sig));

f_s=round(fs/2);
cutoff=param/f_s;

b1=fir1(8,cutoff);
    envmax=filtfilt(b1,1,env);
end
