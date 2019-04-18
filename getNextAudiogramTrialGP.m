function [f, L, dInformation, vHyperParameters] = getNextAudiogramTrialGP( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, dStepSize, LMaxSPL )

%% version of the JASA paper
%% i.e. initial grid required (strongly recommended) before first run

[hyp, inffunc, meanfunc, covfunc, likfunc, delta, inffuncalt, bPlot] = setupGP();

%% prepare grid
LgridMin = -10;
if nargin < 7
    LgridMax = 77;
else
    fInitial = 2.^(log2(nMinF):dStepSize:log2(nMaxF));
    LgridMax = min( LMaxSPL - MAP_MG2007(fInitial) + FlatAtEardrumCorrection(fInitial) ) 
end

[x,y,t, tforig, tLorig] = getGridAudiogram( vFPresented, vLPresented, vAnswers, nMinF, nMaxF, dStepSize, LgridMin, LgridMax );

%% GP
[hyp, ~, ~, fmu, fs2, lp] = runGP(hyp, inffunc, inffuncalt, meanfunc, covfunc, likfunc, x, y, t, 1, tforig, tLorig );

%% mutual information

[f, L, dInformation, I] = getMostInformativePoint( fmu, fs2, delta, tforig, nMinF, LgridMin, dStepSize );

% disp(['Max I = ' num2str(dInformation) ' bit at L = ' num2str(L) ' dB and f = ' num2str(f) ' Hz']);

if (bPlot)
    plotGPSimple( lp, fmu, fs2, I, tforig, tLorig, vFPresented, vLPresented, vAnswers );
end

vHyperParameters = [exp(hyp.cov) hyp.mean];