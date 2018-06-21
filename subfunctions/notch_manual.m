function data_filtered = notch_manual(data_raw,fs,f0)

wo = f0/(fs/2);  
bw = 10/35;
[b,a] = iirnotch(wo,bw);
data_filtered = filtfilt(b,a,data_raw);

% %#Nyquist frequency
% freqRatio = f0/fn;      %#ratio of notch freq. to Nyquist freq.
% notchWidth = 0.5;       %#width of the notch
% 
% %Compute zeros
% notchZeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];
% 
% %#Compute poles
% notchPoles = (1-notchWidth) * notchZeros;
% 
% %figure;
% %zplane(notchZeros.', notchPoles.');
% 
% b = poly( notchZeros ); % Get moving average filter coefficients
% a = poly( notchPoles ); % Get autoregressive filter coefficients

