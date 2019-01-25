function [f, L, dInformation, vHyperParameters] = getNextAudiogramTrialGP( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, nStepSize, LMaxSPL )

% return the frequency and the level to be presented in the next trial
% by calculating a GP for classification and choose the most informative
% pair
% dInformation is the information of that pair in bit, vHyperParameters the
% hyperparameters of the GP (4 elements for covariance and 1 for the mean)
% parameters that need to be passed are the frequencies and levels that
% were presented so far (vFPresented, vLPresented), and the corresponding
% responses (vAnswers, 0 and 1), the minimum and maximum frequency to be
% considered (in Hz), the step size of the grid in octaves and the maximum
% level, i.e. the SPL of a full-scale sinusoid

bPlot = 0; % plot current estimate in GUI

delta = 0.01;

infgen = @infEP;
infalt = @infLaplace;

meanfunc = @meanConst;
hyp.mean = 0;
covfunc = @covComb;   %  SE for frequency (1st column), linear for SPL (2nd column); provide covComb!
likfunc = @likErfLapse;

hyp.cov = log([3 0.5 3]);                 % priors: 1 factor for lin. intensity, 2 length scale for frequency, 3 factor for SE frequency
hyp.cov = [hyp.cov log(0)];            % add noise
covfunc = {@covSum,{covfunc,@covNoise}};

prior.cov ={@priorClamped,@priorClamped,@priorClamped,@priorClamped};
inffunc = {@infPrior,infgen,prior};
inffuncalt = {@infPrior,infalt,prior};

%% prepare grid
vFLog = log2( vFPresented );
LgridMin = -10;
fInitial = 2.^(log2(nMinF):nStepSize:log2(nMaxF));
LgridMax = min( LMaxSPL - MAP_MG2007(fInitial) + FlatAtEardrumCorrection(fInitial) );
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

hyp.cov
%% GP
try
    hyp = minimize(hyp, @gp, -200, inffunc, meanfunc, covfunc, likfunc, x, y);
catch
    hyp = minimize(hyp, @gp, -200, inffuncalt, meanfunc, covfunc, likfunc, x, y);
end

try
    [a, b, la, lb, lp] = gp(hyp, inffunc, meanfunc, covfunc, likfunc, x, y, t, ones(length(t),1) );
catch
    [a, b, la, lb, lp] = gp(hyp, inffuncalt, meanfunc, covfunc, likfunc, x, y, t, ones(length(t),1) );
end

%% mutual information

H1 = BinaryEntropy( GaussianCDFDelta( la ./ sqrt( lb + 1 ), delta ) );                 % eq. 3
H2 = ExpectedEntropy( la, lb, delta );
I = H1 - H2; 

%% retrieve point with maximum information

mIReshaped  = reshape(I, size(tforig));
[MaxL,IndMaxL] = max( mIReshaped );
[~,IndMaxf] = max( MaxL );
dInformation = mIReshaped(IndMaxL(IndMaxf),IndMaxf);
fLog = IndMaxf / 10 + log2( nMinF ) - nStepSize;
f    = 2.^fLog;
L    = IndMaxL(IndMaxf) + LgridMin - 1;

disp(['Max I = ' num2str(dInformation) ' bit at L = ' num2str(L) ' dB and f = ' num2str(f) ' Hz']);

if (bPlot)
    mYt = reshape(exp(lp), size(tforig));
    IndicesC1 = nonzeros( (1:length(vAnswers)) .* vAnswers );   % Indices which elements of c are 1
    IndicesC2 = nonzeros( (1:length(vAnswers)) .* ~vAnswers );
    hold off;
    contour(tforig, tLorig, mYt, 0.1:0.1:0.9);
%     pcolor(tforig, tLorig, reshape(I, size(tforig)) );
%     shading interp
    hold on;
    plot( log2(vFPresented(IndicesC1)), vLPresented(IndicesC1), 'bo' );
    plot( log2(vFPresented(IndicesC2)), vLPresented(IndicesC2), 'r+' );
%     cb = colorbar;
%     caxis([0 1])
%     ylabel(cb,'I [bit]');
    [~, h] = contour(tforig, tLorig, mYt, [0.5 0.5],'Color','black');
    set(h, 'LineWidth', 2)
    xlim(log2([nMinF nMaxF]));
    ylim([min(Lgrid) max(Lgrid)]);
    xlabel('log2( f / Hz )');
    ylabel(['L [dB HL]']);
end

vHyperParameters = [exp(hyp.cov) hyp.mean];