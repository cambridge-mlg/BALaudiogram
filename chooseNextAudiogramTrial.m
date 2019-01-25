function [f, L, dInformation, eInitial, vHyperParameters] = chooseNextAudiogramTrial( eInitial, vFPresented, vLPresented, vAnswers, nMinF, nMaxF, dStepSize, LMaxSPL, strSubject, strEar, strStartTime )

% This function calls another function that returns frequency and level to
% be presented in the next trial. This is getNextAudiogramTrialGP for the
% active learning part, but some other functions that consist of if-else
% constructs to get the first 10-15 trials (the 'initial grid')
% For the initial grid trials, dInformation is 1 and vHyperParameters are
% zeros
% For the active-learning trials, dInformation is the information in bits,
% and vHyperParameters the hyper parameters of the Gaussian Process
% eInitial is the stage in which the experiment is. 2 at the beginning when
% it presents a 1-kHz tone, 1 when it queries other frequencies of the
% initial grid, and 0 when in the active learning phase

vHyperParameters = zeros(1,5);

fInitial = 2.^(log2(nMinF):dStepSize:log2(nMaxF));
LMax = min( LMaxSPL - MAP_MG2007(fInitial) + FlatAtEardrumCorrection(fInitial) );
LMax = min([LMax 90]);
% disp(['Maximum level: ' num2str(LMax) ' dB HL']);

if ( eInitial == 2 )  % 1-kHz
    if ( ( sum( vAnswers ) > 0 && sum( vAnswers ) < length( vAnswers ) ) || vLPresented(end) == -10 || ( vLPresented(end) > LMax - 10 && vAnswers(end) == 0 ) )
        eInitial = 1;
    else
        L = getNextAudiogramTrial1kHz( vLPresented, vAnswers );
        f = 1000;
        dInformation = 1;
    end
end
if ( eInitial == 1 ) % audiometric frequencies  
    [f, L] = getNextAudiogramTrialOctaves( vFPresented, vLPresented, vAnswers, nMinF, nMaxF );
    dInformation = 1;
    if ( L > LMax ) % L > ( LMaxSPL - MAP_MG2007(f) + FlatAtEardrumCorrection(f) )
        L = LMax;
    end
    if ( L == vLPresented(end) && f == vFPresented(end) )
        if ( f > 1000 )
            f = 500;
            L1000 = nonzeros(( vFPresented == 1000 ) .* ( vLPresented + 1000 ) );
            L = L1000(end) - 1000;
            if ( L < 60 )
                L = L + 10;
            else
                L = L - 10;
            end
        else
            eInitial = 0;
        end
    end
    if ( f < nMinF )
        eInitial = 0;
    end
end
if ( eInitial == 0 ) % GP
    [f, L, dInformation, vHyperParameters] = getNextAudiogramTrialGP( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, dStepSize, LMaxSPL );
end

save(['out/mat/audiogram ' strSubject ' ' strEar ' ' strStartTime '.mat'],'vFPresented','vLPresented','vAnswers');