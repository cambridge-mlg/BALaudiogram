function L = MAP_MG2007(f)

% Minimum audible pressure, SPL at eardrum

TF = [125  250  500  750  1000 1500 2000 3000 4000 6000 8000;
      23.2 13.3 7.0  5.9  5.7  9.0  11.6 10.3 9.7  13.1 15.3];
  
L = interp1( TF(1,:), TF(2,:), f, 'pchip');