function out = GaussianCDFDelta( in, delta )

% Gaussian cumulative density function scaled to be between delta and
% 1-delta (lapse rate)

out = (1/2)*(1+erf(in/sqrt(2)))*(1-2*delta) + delta;