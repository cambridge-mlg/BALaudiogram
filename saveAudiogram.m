function saveAudiogram(strOutputDir, strSubject, strTime, vFPresented, vLPresented, vAnswers, nMinF, nMaxF, nStepSize, strEar, vInformation, mHyperParameters, vRT )

%% save each trial
fid = fopen([strOutputDir '/' strSubject ' ' strEar ' ' strTime ' all trials.txt'],'at+');
for i = 1:length(vFPresented)
    fprintf(fid,'%5.0f\t%5.0f\t%5.0f\t%5.0f\t%7.2f',i,vFPresented(i),vLPresented(i),vAnswers(i),vInformation(i));
        for j=1:5
            fprintf(fid,'\t%7.2f',mHyperParameters(i,j));
        end
    fprintf(fid,'\t%7.4f',vRT(i));
    fprintf(fid, '\n');
end
fclose(fid);


%% GP
delta = 0.01;

infgen = @infEP;
infalt = @infLaplace;

meanfunc = @meanConst;
hyp.mean = 0;
covfunc = @covComb;   %  SE for frequency (1st column), linear for SPL (2nd column); provide covComb!
likfunc = @likErfLapse;

hyp.cov = log([3 0.5 3]);                 % priors: 1 factor for lin. intensity, 2 length scale for frequency, 3 factor for SE frequency
hyp.cov = [hyp.cov log(0)];            % add noise
covfunc = {@covSum,{covfunc,@covNoise}};

prior.cov ={@priorClamped,@priorClamped,@priorClamped,@priorClamped}; % change to have length scale optimized!
inffunc = {@infPrior,infgen,prior};
inffuncalt = {@infPrior,infalt,prior};

%% prepare grid
vFLog = log2( vFPresented );
LgridMin = -10;
LgridMax = 120;
Lgrid = LgridMin:LgridMax;
fgrid = log2( nMinF ):nStepSize:log2( nMaxF );
tf = meshgrid(fgrid,Lgrid);
tforig = tf;
tf = tf(:);
tL = meshgrid(Lgrid,fgrid);
tL = tL';
tLorig = tL;
tL = tL(:);
t  = [tf tL];
x = [vFLog;vLPresented]';
y = 2 * ( vAnswers - 0.5 ); y = y';

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

mYt = reshape(exp(lp), size(tforig));

%% find 50% for each frequency

vFL = get50PercentContour( mYt, LgridMin );

fid = fopen([strOutputDir '/' strSubject ' ' strEar ' ' strTime ' by frequency.txt'],'at+');
for i = 1:length(vFL)
    fprintf(fid,[num2str(2.^(log2(nMinF)+nStepSize*(i-1))) '\t' num2str(vFL(i)) '\n' ]);
end
fclose(fid);
fid = fopen([strOutputDir '/' strSubject ' ' strEar ' by frequency.txt'],'wt+');
for i = 1:length(vFL)
    fprintf(fid,[num2str(2.^(log2(nMinF)+nStepSize*(i-1))) '\t' num2str(vFL(i)) '\n' ]);
end
fclose(fid);

%% plot GP

analyzeSingle3GivenLengthScale( [strOutputDir '/' strSubject ' ' strEar ' ' strTime ' all trials.txt'], 0.5 );

% print([strOutputDir '/' strSubject ' ' strEar ' ' strTime ' audiogram'],'-dpng')

