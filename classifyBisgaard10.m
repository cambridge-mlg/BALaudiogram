function [nOut strOut] = classifyBisgaard10( TH )

% Classify audiogram according to Bisgaard et al. (2010)
% DOI: 10.1177/1084713810379609
%
%TH must be given at 125, 250, 500, 750, 1000, 1500, 2000, 3000, 4000 and 6000
%Hz (125 will be discarded, 8000 Hz would be discarded)
%may contain nan
%TH is threshold in dB HL

mBisgaard = [ 10 10 10   10  10  15  20  30  40;
              20 20 22.5 25  30  35  40  56  50;
              35 35 35   40  45  50  55  60  65;
              55 55 55   55  60  65  70  76  80;
              65 70 72.5 75  80  80  80  80  80;
              75 80 82.5 85  90  90  95  100 100;
              90 95 100  105 105 105 105 105 105;
              10 10 10   10  10  15  30  55  70;
              20 20 22.5 25  35  55  75  95  95;
              30 35 47.5 60  70  75  80  80  85];
          
cstrBisgaard = {'N1','N2','N3','N4','N5','N6','N7','S1','S2','S3'};

TH = TH(2:10);

indEval = ~isnan(TH);

nDiscrepancy = inf;
for i = 1:10
    nThisDiscrepancy = mean( ( TH(indEval) - mBisgaard(i,indEval) ).^2 );
    if nThisDiscrepancy < nDiscrepancy
        nDiscrepancy = nThisDiscrepancy;
        nOut = i;
    end
end

strOut = cstrBisgaard{nOut};
