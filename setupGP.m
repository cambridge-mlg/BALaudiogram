function [hyp, inffunc, meanfunc, covfunc, likfunc, delta, inffuncalt, dStepSize, bPlot] = setupGP()

bPlot = 0;
dStepSize = 0.1;

delta = 0.01;

infgen = @infEP;
infalt = @infLaplace;

meanfunc = {@meanConst};
hyp.mean = 0;
covfunc = @covComb;   %  SE for frequency (1st column), linear for SPL (2nd column); provide covComb!
likfunc = @likErfLapse; % fixed delta of 0.01!

hyp.cov = log([3 0.5 3]);                 % priors: 1 factor for lin. intensity, 2 length scale for frequency, 3 factor for SE frequency
hyp.cov = [hyp.cov log(0)];            % add noise
covfunc = {@covSum,{covfunc,@covNoise}};

prior.cov ={@priorClamped,@priorClamped,@priorClamped,@priorClamped};
inffunc = {@infPrior,infgen,prior};
inffuncalt = {@infPrior,infalt,prior};