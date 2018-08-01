classdef header
    properties
        fs
        nchan
        labels
        badchan
        fpath
        image
    end
    methods
        function self = header(fs,nchan, labels,badchan,fpath,image)    % Constructor.
            if nargin < 6
                self.image =[];
            else
                self.image = image;
            end
            self.fs = fs;
            self.nchan = nchan;
            self.labels = labels;
            self.fpath = fpath;
            self.badchan=badchan;
        end
        
        function self = nchannels(self)
            self = self.nchan;
        end
        function self = chanlabels(self,id)
            if nargin<2 || isempty(id)
                self = self.labels;
            else
                self = self.labels(id);
            end
        end
        function self = badchannels(self)
            self = self.badchan;
        end
        function self = path(self)
            self = self.fpath;
        end
        function self = fsample(self)
            self = self.fs;
        end
        function self = brain3d(self)
            self = self.image;
        end
    end
end