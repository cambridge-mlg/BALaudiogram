function L = FlatAtEardrumCorrection(f)

% TF defines the transfer function of the headphones, measured at the eardrum
% present one was derived from KEMAR measurements for Sennheiser HDA 200
% procedure described in JASA paper used ISO 389-8
% MUST be adjusted for your headphones

TF = [50    63    80    100   125   160   200   250   315   400   500   630   750   800   1000  1250  1500  1600 ...
      2000  2500  3000  3150  4000  5000  6000  6300  8000  9000  10000 11200 12500 14000 15000 16000;
%       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
      -23.6 -18.0 -12.3 -7.3  -2.9  0.4   1.7   2.0   2.2   2.2   2.3   2.0   0.3   -0.2  0.0   -1.9  -2.6  -2.4 ...
      1.8   8.3   6.8   5.7   0.3   -3.9  -4.5  -4.3  -5.2  -8.9  -8.4  -10.8 -14.9 -19.9 -28.1 -36.2];
  
L = interp1( TF(1,:), TF(2,:), f, 'pchip' );