function [f, L] = getNextAudiogramTrialOctaves( vFPresented, vLPresented, vAnswers, nMinF, nMaxF )

% If-else constructs to determine trials after those at 1 kHz and before
% the active-learning mechanism is started. See method section of
% Schlittenlacher et al. (2018), JASA.

if ( vFPresented(end) >= 2 * nMinF && vFPresented(end) <= 0.5 * nMaxF )
    if ( vFPresented(end) >= 1000 )
        f = 2 * vFPresented(end);
        if ( f > nMaxF )
            f = 500;
        end
    else
        f = 0.5 * vFPresented(end);
    end
else
    f = vFPresented(end);
end

if( f < 2 * nMinF || f > 0.5 * nMaxF )
    L = getNextAudiogramTrialBorderFrequency( f, vFPresented, vLPresented, vAnswers );
else
    if ( vAnswers(end) == 1 )
        L = vLPresented(end) - 10;
    else
        L = vLPresented(end) + 10;
    end
end

if ( L == -999 )   % -999 returned as 'code' by getNextAudiogramTrialBorderFrequency
    if( f < 2 * nMinF )
        f = 0.5 * f;
    else
        f = 500;
    end
end

if ( f == 500 )
    L1000 = nonzeros(( vFPresented == 1000 ) .* ( vLPresented + 1000 ) );
    L = L1000(end) - 1000;
    if ( L < 60 )
        L = L + 10;
    else
        L = L - 10;
    end
end

if ( L < -10 && L ~= -999 )
    L = -10;
end