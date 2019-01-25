function out = GaussianCDF( in )

% Gaussian cumulative density function

out = (1/2)*(1+erf(in/sqrt(2)));