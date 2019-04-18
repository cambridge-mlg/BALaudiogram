function [f, L] = getNextAudiogramTrialOctaves( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, LMax )

% If-else constructs to determine trials after those at 1 kHz and before
% the active-learning mechanism is started. See method section of
% Schlittenlacher et al. (2018), JASA.
%
% version 3: adjust to work with any start frequency

bJumped = 0; % jump from going towards higher frequencies to going towards lower frequencies

if ( vFPresented(end) >= vFPresented(1) )
    f = 2 * vFPresented(end);
    if ( f >= nMaxF )        
        f = nMaxF; % but check if border frequency completed -> jump to 0.5 start f
        if BorderFrequencyCompleted( nMaxF, vFPresented, vLPresented, vAnswers, LMax )
            bJumped = 1;
        end
    end
end
if ( vFPresented(end) < vFPresented(1) || bJumped )
    if ( bJumped )
        f = 0.5 * vFPresented(1);
    else
        f = 0.5 * vFPresented(end);
    end
    if ( f <= nMinF )
        f = nMinF;  % if that border frequency was already completed, this function won't be called -> always okay to set to min
    end
end

if ( bJumped ) % consider the very first frequency for determining the level
    vAnswers    = vAnswers( ( vFPresented == vFPresented(1) ) );    
    vLPresented = vLPresented( ( vFPresented == vFPresented(1) ) );
    vFPresented = vFPresented( ( vFPresented == vFPresented(1) ) );
end

if ( ( f == nMinF || f == nMaxF ) && ( vFPresented(end) == nMinF  || vFPresented(end) == nMaxF ) )
    L = getNextAudiogramTrialBorderFrequency( f, vFPresented, vLPresented, vAnswers );
else
    if ( vAnswers(end) == 1 ) 
        L = vLPresented(end) - 10;
    else
        L = vLPresented(end) + 10;
    end
end