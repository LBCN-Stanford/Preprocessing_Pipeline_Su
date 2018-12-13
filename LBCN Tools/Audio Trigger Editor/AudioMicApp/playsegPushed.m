function playsegPushed(varargin)

    %evt = varargin{1};
    if strcmpi(varargin{2}.Key, 'shift')
        signal=varargin{4};
        fs=varargin{3};
        segplayer = audioplayer(signal,fs);
        t1 = get(gca,'xlim');
        t1 = t1(1);
        audpointer = line(gca,[t1 t1],[-1 1],'color',[0.93 0.69 0.13],'linewidth',2);
        %set(segplayer,'TimerFcn',{@timerline,audpointer}, 'TimerPeriod', 0.1);
        play(segplayer,1);
        while strcmp(segplayer.Running,'on')
            currSample = get(segplayer,'CurrentSample');
            set(audpointer,'XData',[currSample currSample]/fs+t1);drawnow
            %pause(0.001);
        end
    else 
        return;
    end 
end
