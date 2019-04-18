function [f, L, dInformation, eInitial, vHyperParameters] = chooseNextAudiogramTrial( eInitial, vFPresented, vLPresented, vAnswers, nMinF, nMaxF, dStepSize, LMaxSPL, strSubject, strEar, strStartTime )

% choose the next frequency and level
% initial grid: if eInitial is 2, pick at first frequency, if 1, pick at
% octave steps, active learning when eInitial is 0

vHyperParameters = zeros(1,5);

fInitial = 2.^(log2(nMinF):dStepSize:log2(nMaxF));
LMax = min( LMaxSPL - MAP_MG2007(fInitial) + FlatAtEardrumCorrection(fInitial) ); % maximum level that can be presented at all frequencies
LMax = min([LMax 77]); % hard code maximum level for safety (77 used for not any loud sounds at all, change to 90 or 100 if apparatus can do it. No very high levels at normal hearing were presented with this procedure in our JASA study.

if ( eInitial == 2 )  % starting frequency
    if ( ( any(vAnswers==0) && any(vAnswers==1) ) || vLPresented(end) == -10 || ( vLPresented(end) > LMax - 10 && vAnswers(end) == 1 ) )
        eInitial = 1;
    else
        L = getNextAudiogramTrial1kHz( vLPresented, vAnswers );
        f = vFPresented(1);
        dInformation = 1;
    end
end
if ( eInitial == 1 ) % octave frequencies 
    if BorderFrequencyCompleted( nMinF, vFPresented, vLPresented, vAnswers, LMax )
        eInitial = 0;
    else
        [f, L] = getNextAudiogramTrialOctaves( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, LMax );
        dInformation = 1;
        if ( L > LMax )
            L = LMax;
        end
    end
end
if ( eInitial == 0 ) % GP
    [f, L, dInformation, vHyperParameters] = getNextAudiogramTrialGP( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, dStepSize, LMaxSPL );
end

save(['out/mat/audiogram ' strSubject ' ' strEar ' ' strStartTime '.mat'],'vFPresented','vLPresented','vAnswers'); % save in mat file before each trial, not to loose any data