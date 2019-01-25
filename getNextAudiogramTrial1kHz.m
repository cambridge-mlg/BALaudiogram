function L = getNextAudiogramTrial1kHz( vLPresented, vAnswers )

% Choose the level of the first trials at 1 kHz based on simple rules

if ( vLPresented(end) == 60 )
    if ( vAnswers(end) == 1 )
        L = 40;
    else
        L = 70;
    end
elseif ( vLPresented(end) < 60 )
    L = vLPresented( end ) - 20;
    if ( L < -10 )
        L = -10;
    end
else
    L = vLPresented( end ) + 10;
end