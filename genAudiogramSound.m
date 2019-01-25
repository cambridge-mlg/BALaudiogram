function s = genAudiogramSound( f, L, Fs, LMaxLevelSPL, strEar, nPulses, nPulseDuration, nPulsePause, dRiseFall )

% generate sound
% can be modified easily for any experiment that uses frequency and level
% as parameters, and is monotonic in level and smooth in frequency. E.g.
% masked thresholds

t = 1:round(nPulseDuration/1000*Fs);
sPulse = sin( t / Fs * 2 * pi * f );
sPulse = sPulse * 10 ^ ( ( L - (LMaxLevelSPL - MAP_MG2007(f) ) - FlatAtEardrumCorrection(f) ) / 20 );
sPulse = addFallRise(sPulse,Fs,dRiseFall,'h');
sPause = zeros(1, round( nPulsePause/1000 * Fs ) );

s = sPulse;
for i=1:(nPulses-1)
    s = [s sPause sPulse];
end
s = s';

if ( strcmp( strEar, 'L' ) )
    s = [ s zeros(size(s)) ];
else
    s = [ zeros(size(s)) s ];
end