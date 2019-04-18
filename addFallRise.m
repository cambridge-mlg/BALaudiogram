function erg = addFallRise(s,Fs,d,shape,gaussdev)

% add rise and fall time to a stimulus

if nargin < 5
    gaussdev = 3; % number of SDs if shape is Gaussian
end
if nargin < 4
    shape = 'h';
end
if nargin < 3
    d = 0.005;
end
if nargin < 2
    Fs = 48000;
end

nSamples = d * Fs;
w = ones(size(s));

if (shape == 'l')
    w(1:nSamples) = (0:(nSamples-1))./nSamples;
    w((length(w)-nSamples+1):(length(w))) = ((nSamples-1):-1:0)./nSamples;
elseif (shape == 'g')
    w2 = window(@gausswin,nSamples*2,gaussdev);
    w(1:nSamples) = w2(1:nSamples);
    w((length(w)-nSamples+1):(length(w))) = w2((nSamples+1):(2*nSamples));
elseif (shape == 'h')
    w2 = hann(nSamples*2);
    w(1:nSamples) = w2(1:nSamples);
    w((length(w)-nSamples+1):(length(w))) = w2((nSamples+1):(2*nSamples));
end

erg = s.*w;
