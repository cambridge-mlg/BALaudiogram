function [tforig, tLorig, mYt] = analyzeSingle3GivenLengthScale( filenameData, dLengthScale )

% same as analyzeSingle3, but do not optimize hyperparameters (except mean)

bPlot = 1;

nFontSize = 16;

cR = linspace(1,1,100);
cG = linspace(1,0.08,100);
cB = linspace(1,0.58,100);
cmap = [cR' cG' cB'];

%% data

mData = importdata( filenameData );

f = mData(:,2);f=f';
L = mData(:,3);L=L';
c = mData(:,4);c=c';

Lmin = -10;
Lmax = max(L);
fmin = min(f);
fmax = max(f);

x = [f;L]';
y = 2 * ( c - 0.5 ); y = y';

%% setup GP

delta = 0.01;

infgen = @infEP;
infalt = @infLaplace;

meanfunc = @meanConst;
hyp.mean = 0;
covfunc = @covComb;   %  SE for frequency (1st column), linear for SPL (2nd column); provide instead of covComb!
likfunc = @likErfLapse;

hyp.cov = log([3 dLengthScale 3]);                 % priors: 1 factor for lin. intensity, 2 length scale for frequency, 3 factor for SE frequency

prior.cov ={@priorClamped,@priorClamped,@priorClamped};
prior.mean = {[]};
inffunc = {@infPrior,infgen,prior};
inffuncalt = {@infPrior,infalt,prior};

%% grid

IndicesC1 = nonzeros( (1:length(c)) .* c );   % Indices which elements of c are 1
IndicesC2 = nonzeros( (1:length(c)) .* ~c );


vFLog = log2( f);
LgridMin = -10;
LgridMax = max(L);
Lgrid = LgridMin:LgridMax;
fgrid = log2( min(f) ):0.1:log2( max(f) );
tf = meshgrid(fgrid,Lgrid);
tforig = tf;
tf = tf(:);
tL = meshgrid(Lgrid,fgrid);
tL = tL';
tLorig = tL;
tL = tL(:);
t  = [tf tL];
x = [vFLog;L]';
y = 2 * ( c - 0.5 ); y = y';

%% GP
try
    hyp = minimize(hyp, @gp, -200, inffunc, meanfunc, covfunc, likfunc, x, y);
catch
    hyp = minimize(hyp, @gp, -200, inffuncalt, meanfunc, covfunc, likfunc, x, y);
end

try
    [a, b, la, lb, lp] = gp(hyp, inffunc, meanfunc, covfunc, likfunc, x, y, t, ones(length(t),1) );
catch
    [a, b, la, lb, lp] = gp(hyp, inffuncalt, meanfunc, covfunc, likfunc, x, y, t, ones(length(t),1) );
end

%% plot

mYt = reshape(exp(lp), size(tforig));
mMuPlusSigma = reshape(la+sqrt(lb), size(tforig));
mMuMinusSigma = reshape(la-sqrt(lb), size(tforig));

if (bPlot)
    figure;
    % pcolor(tforig, tLorig, reshape(I, size(tforig)) )
    % pcolor(tforig, tLorig, mYt )
    % hold on;
    % caxis([0 1])
    plot( log2(f(IndicesC1)), L(IndicesC1), 'bo', 'LineWidth',1.5 );
    hold on;
    plot( log2(f(IndicesC2)), L(IndicesC2), 'r+', 'LineWidth',1.5 );
    % cb = colorbar;
    % caxis([0 1])
    % ylabel(cb,'Information [bit]');
    % ylabel(cb,'information /bits');
    [c h] = contour(tforig, tLorig, mYt, [0.5 0.5],'Color','black');
    set(h, 'LineWidth', 2)
    contour(tforig, tLorig, mMuPlusSigma, [0 0],'Color','black');
    contour(tforig, tLorig, mMuMinusSigma, [0 0],'Color','black');
    xlim([log2(min(f)) log2(max(f))]);
    ylim([-10 max(Lgrid)+5]);
    shading interp
    xlabel('Frequency [Hz]');
    ylabel(['Hearing loss [dB]']);
    l = legend('"yes" answer','"no" answer','threshold','Location','NW');
    set(gca,'XTick',log2([125 250 500 1000 2000 4000 8000]));
    set(gca,'XTickLabel',[125 250 500 1000 2000 4000 8000]);
    set(gca,'FontSize',nFontSize);
    set(l,'FontSize',nFontSize);

    print(['out/fig/' filenameData(5:24) ' GP final'], '-dpng', '-r0');
end

c = reshape(la, size(tforig));
disp( 1/ ( ( c(size(c,1),1)-c(1,1) ) / ( size(c,1) - 1 ) ) )
