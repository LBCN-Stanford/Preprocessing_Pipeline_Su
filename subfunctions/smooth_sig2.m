function ev=smooth_sig2(sig,fs)
[b3,a3]=butter(2,10/(fs/2));

        sigsq=2*sig.*sig;
        
        ev=real(sqrt(filtfilt(b3,a3,sigsq)));