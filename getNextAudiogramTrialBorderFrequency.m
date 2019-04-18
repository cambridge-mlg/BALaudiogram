function L = getNextAudiogramTrialBorderFrequency( f, vFPresented, vLPresented, vAnswers )

% check border frequencies (125 Hz, 8 kHz) of initial grid
% See method section of Schlittenlacher et al. (2018), JASA.
% adjusted to work with any start and border frequency (version 3)

if ( ~any(vFPresented == f ) ) % this border frequency was not queried yet
    if ( vAnswers(end) == 1 ) 
        L = vLPresented(end) - 10;
    else
        L = vLPresented(end) + 10;
    end
else
    vAnswers    = vAnswers( ( vFPresented == f ) );    % only care about previous responses at border frequency
    vLPresented = vLPresented( ( vFPresented == f ) );
    if ( vLPresented(end) == -10 && vAnswers(end) == 1 ) % subject too good, return -999 level (not used anymore)
        L = -999;
    else
        if ( length( vAnswers ) == 1 )            % one answer at border frequency -> 20 dB step
            if ( vAnswers(end) == 1 ) 
                L = vLPresented(end) - 20;
            else
                L = vLPresented(end) + 20;
            end
        else % two or more responses at that frequency -> check if a 1 and 0 are both present
            if ( any( vAnswers == 1 ) && any( vAnswers == 0 ) )  % 1 detected, 1 undected -> level inbetween
                if ( vAnswers(end) == 1 )
                    L = vLPresented(end) - 10;
                else
                    L = vLPresented(end) + 10;
                end
            else                               % 20-dB step
                if ( vAnswers(end) == 1 )
                    L = vLPresented(end) - 20;
                else
                    L = vLPresented(end) + 20;
                end
            end
        end
    end
end
if ( L < -10 )
    L = -10;            % minimum level to present is -10 dB HL (limitation of sound card/perfect hearing anyway)
end