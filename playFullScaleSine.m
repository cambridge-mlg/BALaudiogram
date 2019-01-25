% play a full-scale 1-kHz sinusoid -> check calibration

Fs = 48000;
t = 1:(Fs*30);
s1 = sin(t/Fs*2*pi*1000);
s2 = zeros(size(s1));
s = [s1' s2'];

player = audioplayer( [s1' s2'], Fs, 24 );
playblocking(player);