function [f, L, information, I] = getMostInformativePoint( fmu, fs2, delta, tforig, nMinF, LgridMin, dStepSize )

H1 = BinaryEntropy( GaussianCDFDelta( fmu ./ sqrt( fs2 + 1 ), delta ) );                 % eq. 3
H2 = ExpectedEntropy( fmu, fs2, delta );
I = H1 - H2; 

%% retrieve point with maximum information

mIReshaped  = reshape(I, size(tforig));
[MaxL,IndMaxL] = max( mIReshaped );
[~,IndMaxf] = max( MaxL );
information = mIReshaped(IndMaxL(IndMaxf),IndMaxf);
fLog = IndMaxf * dStepSize + log2( nMinF ) - dStepSize;
f    = 2.^fLog;
L    = IndMaxL(IndMaxf) + LgridMin - 1;