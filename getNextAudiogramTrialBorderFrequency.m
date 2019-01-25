function L = getNextAudiogramTrialBorderFrequency( f, vFPresented, vLPresented, vAnswers )

% check border frequencies (125 Hz, 8 kHz) of initial grid
% See method section of Schlittenlacher et al. (2018), JASA.

if ( ~any(vFPresented == f ) )
    if ( vAnswers(end) == 1 )
        L = vLPresented(end) - 10;
    else
        L = vLPresented(end) + 10;
    end
else
    vAnswers    = nonzeros( ( vAnswers + 1 ) .* ( vFPresented == f ) );
    vAnswers    = vAnswers - 1;
    vLPresented = nonzeros( ( vLPresented + 1000 ) .* ( vFPresented == f ) );
    vLPresented = vLPresented - 1000;
    vFPresented = nonzeros( vFPresented .* ( vFPresented == f ) );
    if ( vLPresented(end) == -10 && vAnswers(end) == 1 ) % -10 dB detected, return L = -999
        L = -999;
    else
        if ( length( vAnswers ) == 1 )            % 20-dB step
            if ( vAnswers(end) == 1 )
                L = vLPresented(end) - 20;
            else
                L = vLPresented(end) + 20;
            end
        else
            if ( any( vAnswers == 1 ) && any( vAnswers == 0 ) )  % 1 detected, 1 undected -> level inbetween
                if ( length( vAnswers ) == 2 )                   % two answers only, consider last only
                    if ( vAnswers(end) == 1 )
                        L = vLPresented(end) - 10;
                    else
                        L = vLPresented(end) + 10;
                    end
                else                                                
                    if ( vAnswers( end - 1 ) ==  vAnswers( end - 2 ) )
                        if ( vAnswers(end) == 1 )
                            L = vLPresented(end) - 10;
                        else
                            L = vLPresented(end) + 10;
                        end
                    else
                        L = -999;
                    end
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