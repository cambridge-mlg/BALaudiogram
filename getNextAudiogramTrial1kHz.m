function L = getNextAudiogramTrial1kHz( vLPresented, vAnswers )

% Choose the level of the first trials at 1 kHz based on simple rules
%
% Version 3: Works with any starting frequency and level

if ( vLPresented(end) == vLPresented(1) )
    if ( vAnswers(end) == 1 ) % tone heard -> reduce level by 20 dB
        L = vLPresented(end) - 20;
    else
        L = vLPresented(end) + 10; % not heard -> increase level by 10 dB
    end
elseif ( vLPresented(end) < vLPresented(1) )
    if ( vAnswers(end) == 1 )
        L = vLPresented( end ) - 20; % reduce by 20 dB after further positive response
             if ( L < -10 )
                 L = -10;            % minimum level to present is -10 dB HL (limitation of sound card/perfect hearing anyway)
             end
    else
         L = vLPresented( end ) + 10; % go out
    end
else
    if ( vAnswers(end) == 1 ) % get out
        L = vLPresented( end ) - 5; %% level for next tone (i.e. 2 kHz if started at 1 kHz)
             if ( L < -10 )         
                 L = -10;
             end
    else
        L = vLPresented( end ) + 10;
    end
end