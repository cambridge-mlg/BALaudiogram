function out = ExpectedEntropy( fmu, fs2, delta )

% second part of mutual information. See also Houlsby et al. 2011

nBins = 101;

out = zeros( size( fmu ) );
for i=1:size(fmu,1)
    for j=1:size(fmu,2)
        dStepSize = 2 * 5 * sqrt( fs2(i,j) ) / nBins;
        k = linspace( fmu(i,j) - 5 * sqrt( fs2(i,j) ), fmu(i,j) + 5 * sqrt( fs2(i,j) ), nBins );
        out(i,j) = sum( BinaryEntropy( GaussianCDFDelta( k, delta ) ) .* normpdf( k, fmu(i,j), sqrt( fs2(i,j) ) ) ) * dStepSize;
    end
end