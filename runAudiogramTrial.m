function runAudiogramTrial( f, L, Fs, LMaxLevelSPL, pbYes, pbNo, tIndicateSound, editInstruction, strEar, nPulses, nPulseDuration, nPulsePause, dRiseFall )

% run a trial: hide buttons, play sound, show buttons. nothing else

disp(['f: ' num2str(f) ' Hz, L = ' num2str(L) ' dB HL']);

set(pbNo,'Visible', 'off');
set(pbYes,'Visible', 'off');
set(editInstruction,'Visible', 'off');
set(tIndicateSound,'Visible', 'on');

s = genAudiogramSound( f, L, Fs, LMaxLevelSPL, strEar, nPulses, nPulseDuration, nPulsePause, dRiseFall );

player = audioplayer( s, Fs, 24 );
playblocking(player);

tic
set(pbNo,'Visible', 'on');
set(pbYes,'Visible', 'on');
% set(editInstruction,'Visible', 'on');
set(tIndicateSound,'Visible', 'off');