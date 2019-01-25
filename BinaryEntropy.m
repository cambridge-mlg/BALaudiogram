function out = BinaryEntropy( in )

% Binary entropy for 0 <= in <= 1
% avoid NaN for p = 0 and p = 1
% sets output to 0 for all values < 10^-10 or > 1-10^-10

in = in .* ( in >= 10^-10 & in <= 1 - 10^-10 ) + 10^-11 * (in < 10^-10 ) + (1-10^-11) * (in > (1-10^-10) );
out = zeros( size(in) ) + ( -in .* log2(in) - (1 - in) .* log2(1-in) ) .* ( in >= 10^-10 & in <= 1 - 10^-10 );