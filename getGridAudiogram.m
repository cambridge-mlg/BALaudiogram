function[x, y, t, tforig, tLorig, fInitial] = getGridAudiogram( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, nStepSize, LgridMin, LgridMax )

% generates data x and y for the GP (in log Hz and in dB)
% t are coordinates for prediction
% returns the grids for frequency and level
% and a vector with frequencies in Hz

vFLog = log2( vFPresented );
fInitial = 2.^(log2(nMinF):nStepSize:log2(nMaxF));
Lgrid = LgridMin:LgridMax;
fgrid = log2( nMinF ):nStepSize:log2( nMaxF );
tf = meshgrid(fgrid,Lgrid);
tforig = tf;
tf = tf(:);
tL = meshgrid(Lgrid,fgrid);
tL = tL';
tLorig = tL;
tL = tL(:);
t  = [tf tL];
x = [vFLog;vLPresented]';
y = 2 * ( vAnswers - 0.5 ); y = y';