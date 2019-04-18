function [hyp, ymu, ys2, fmu, fs2, lp] = runGP(hyp, inffunc, inffuncalt, meanfunc, covfunc, likfunc, x, y, t, optimize, tforig, tLorig )

delta = 0.01;

% tforig and tLorig for future use

if nargin < 9
    optimize = 0;
end

if (optimize)
    try
        hyp = minimize(hyp, @gp, -200, inffunc, meanfunc, covfunc, likfunc, x, y);
    catch
        hyp = minimize(hyp, @gp, -200, inffuncalt, meanfunc, covfunc, likfunc, x, y);
    end
end

try
    [ymu, ys2, fmu, fs2, lp] = gp(hyp, inffunc, meanfunc, covfunc, likfunc, x, y, t, ones(length(t),1) );
catch
    [ymu, ys2, fmu, fs2, lp] = gp(hyp, inffuncalt, meanfunc, covfunc, likfunc, x, y, t, ones(length(t),1) );
end