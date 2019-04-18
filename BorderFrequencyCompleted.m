function out = BorderFrequencyCompleted( f, vFPresented, vLPresented, vAnswers, LMax )

% 1 if border frequency f is completed, 0 otherwise

vAnswers    = vAnswers( ( vFPresented == f ) );    
vLPresented = vLPresented( ( vFPresented == f ) );
vFPresented = vFPresented( ( vFPresented == f ) );

if ( isempty( vAnswers ) )
    out = 0;
    return
end

if ( vLPresented(end) <= -10 && vAnswers(end) == 1 )
    out = 1;
    return
end
if ( vLPresented(end) > LMax - 10 && vAnswers(end) == 0 )
    out = 1;
    return
end
if ( length( vAnswers ) == 1 )
    out = 0;
else
    if ( any( vAnswers == 1 ) && any( vAnswers == 0 ) )
        if ( length( vAnswers ) == 2 && abs( vLPresented(end) - vLPresented(end-1) ) > 10 ) % if only 20 dB steps so far
            out = 0;
        else
            out = 1;
        end
    else
        out = 0;
    end
end

