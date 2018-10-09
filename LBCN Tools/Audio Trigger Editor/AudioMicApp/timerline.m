 function results = timerline(varargin)
 player = varargin{1};
 h = varargin{3};
                    currSample = get(player,'CurrentSample');
                    set(h,'XData',[currSample currSample]/player.SampleRate);

             end