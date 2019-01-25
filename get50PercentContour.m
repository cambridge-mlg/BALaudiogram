function out = get50PercentContour( mYt, LgridMin )

% return levels of the 50-percent contour as a function of frequency.
% mYt is the grid of detection probabilities, LgridMin the minimum level in
% this grid. Step size in level is 1 dB.

vFL = zeros(size(mYt,2),1);
for iF = 1:size(mYt,2)
    ThisP = 0;
    iL = 0;
    while (ThisP < 0.5 && iL < size(mYt,1) - 1 )
        iL = iL + 1;
        ThisP = mYt(iL,iF);
    end
    if (iL >= size(mYt,1))
        ThisL = 120;
    else
        ThisP = mYt(iL,iF);
        if ( iL > 1 )
            LastP = mYt(iL-1,iF);
            nDistance = (0.5 - LastP)/(ThisP - LastP);
            ThisL = iL - 1 + nDistance + LgridMin - 1;
        else
            ThisL = LgridMin;
        end
    end
    vFL(iF) = ThisL;
end

out = vFL;