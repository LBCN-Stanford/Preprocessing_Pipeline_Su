function wvm = wv_morlet(cycle, sampleT, fbands, ff)

% cycle - 'wavelet factor'
% sampleT  - sample time in ms
% fbands   - vector of frequencies 
% ff  - frequency to fix Gaussian envelope (sigma = Rtf/(2*pi*ff))
%       Default is ff = f, ie.e, a Morlet transform
%       NB: FWHM = sqrt(8*log(2))*sigma_t;
%
%
% .    Slightly modified from spm morlet wavelet method.
%__________________________________________________________________________
% 
% spm_eeg_morlet generates morlet wavelets for specified frequencies f with
% a specified ratio Rtf, see [1], for sample time ST (ms). One obtains the
% wavelet coefficients by convolution of a data vector with the kernels in
% M. See spm_eeg_tf how one obtains instantaneous power and phase estimates
% from the wavelet coefficients.
%
% [1] C. Tallon-Baudry, O. Bertrand, F. Peronnet and J. Pernier, 1998.
% Induced gamma-Band Activity during the Delay of a Visual Short-term
% memory Task in Humans. The Journal of Neuroscience (18): 4244-4254.
%__________________________________________________________________________
% Copyright (C) 2005-2017 Wellcome Trust Centre for Neuroimaging

% Stefan Kiebel


if nargin < 4
    ff = fbands;
else
    ff = repmat(ff,1,length(fbands));
end

wvm = cell(1,length(fbands));

for i = 1:length(fbands)
    sigma_t = cycle/(2*pi*ff(i));
    t = 0:(sampleT*0.001):(5*sigma_t);
    t = [-t(end:-1:2) t];
    wvm{i} = exp(-t.^2/(2*sigma_t^2)) .* exp(2 * 1i * pi * fbands(i) *t);    
    wvm{i} = wvm{i} ./ (sqrt(0.5*sum(real(wvm{i}).^2 + imag(wvm{i}).^2)));
    wvm{i} = wvm{i} - mean(wvm{i});
end
