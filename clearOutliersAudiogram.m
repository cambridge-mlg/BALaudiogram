function [vFCleared, vLCleared, vCCleared, vLRelCleared] = clearOutliersAudiogram( vTh, vF, vL, vC, minF, dStepSize, stdE )

% clear frequency and level vectors for outliers for plotting/analysis/etc
% outlier is defined as being dStDevs standard deviations 'on the wrong side of the
% threshold'
% not used during active learning in JASA paper

dStDevs = 2.33;

vFind = round( (vF - minF + dStepSize ) / dStepSize );

vLrel = zeros( size( vL ) );
for i=1:length(vL)
    vLrel(i) = vL(i) - vTh( vFind(i) );    
end

vFCleared = [];

for i=1:length( vL )
    if ( ( ( vC(i) == 1 & vLrel(i) > -dStDevs * stdE ) | ( vC(i) == -1 & vLrel(i) < dStDevs * stdE ) ) & vL(i) > -10 )
        
        j = length( vFCleared ) + 1;
        vFCleared(j) = vF(i);
        vLCleared(j) = vL(i);
        vCCleared(j) = vC(i);
        vLRelCleared(j) = vLrel(i);
    end    
end
