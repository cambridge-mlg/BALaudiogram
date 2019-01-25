function out = getTimeMeasurement()

% safe toc call (in case no tic was started)

try
    out = toc
catch
    out = 0;
end