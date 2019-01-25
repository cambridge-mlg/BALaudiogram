function analyzeProcess( strFile )

% This script produces a video of the experiment. It shows each trial
% (stimulus parameters, response, and updated threshold/detection
% probabilities)
% frames are saved to 

addpath(genpath(pwd))
addpath(genpath('../gpml-matlab-v3.6-2015-07-07'))

% strFile = [ 'out/' strFile ' all trials.txt'];

nMinF     = 125;
nMaxF     = 8000;
nStepSize = 0.1;
LgridMax  = 77;

cR = linspace(1,1,100);
cG = linspace(1,0.08,100);
cB = linspace(1,0.58,100);
cmap = [cR' cG' cB'];

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

prior.cov ={@priorClamped,@priorClamped,@priorClamped,@priorClamped};
prior.mean = {[]};
inffunc = {@infPrior,infgen,prior};
inffuncalt = {@infPrior,infalt,prior};

M = importdata( strFile );
bShowGP = 0;
LgridMax  = max( M(:,3) );

for i=1:size(M,1)
    ThisF     = M(i,2);
    ThisL     = M(i,3);
    ThisC     = M(i,4);
    ThisI     = M(i,5);
    if ( i < size(M,1) )
        hyp.cov   = log( M(i+1,6:9) );
        hyp.mean  = M(i+1,10);
    end
    f         = M(1:i,2);  f = f';
    fLog      = log2( f );
    L         = M(1:i,3);  L = L';
    c         = M(1:i,4);  c = c';
    IndicesC1 = nonzeros( (1:length(c)) .* c );   % Indices which elements of c are 1
    IndicesC2 = nonzeros( (1:length(c)) .* ~c );  % Indices of 'No' responses
    fPrev         = M(1:(i-1),2);  fPrev = fPrev'; % previous trial
    fLogPrev      = log2( fPrev );
    LPrev         = M(1:(i-1),3);  LPrev = LPrev';
    cPrev         = M(1:(i-1),4);  cPrev = cPrev';
    IndicesC1Prev = nonzeros( (1:length(cPrev)) .* cPrev );   % Indices which elements of c are 1
    IndicesC2Prev = nonzeros( (1:length(cPrev)) .* ~cPrev );
    
    LgridMin = -10;
    fInitial = 2.^(log2(nMinF):nStepSize:log2(nMaxF));
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
    x = [fLog;L]';
    y = 2 * ( c - 0.5 ); y = y';
    
    if ( ThisI == 1 && M(i+1,5) < 1 )
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
        mMuPlusSigma = reshape(a+b, size(tforig));
        mMuMinusSigma = reshape(a-b, size(tforig));
        H1 = BinaryEntropy( GaussianCDFDelta( la ./ sqrt( lb + 1 ), delta ) );                 % eq. 3
        H2 = ExpectedEntropy( la, lb, delta );
        I = H1 - H2; 
    end
    
    nFontSize = 16;
    
    figure;
    plot( log2(ThisF), ThisL,'kp','LineWidth',1.5,'MarkerSize',10);
    hold on;
    plot( 10^10, 10^10, 'bo', 'LineWidth',1.5 );
    plot( 10^10, 10^10, 'r+', 'LineWidth',1.5 );
    if (bShowGP)
        pcolor(tforig, tLorig, reshape(I, size(tforig)) )  
        hold on;
        cb = colorbar;
        caxis([0 1])
        ylabel(cb,'Information [bit]');
        [c h] = contour(tforig, tLorig, mYt, [0.5 0.5],'Color','black');
        set(h, 'LineWidth', 2)
        contour(tforig, tLorig, mMuPlusSigma, [0 0],'Color','black');
        contour(tforig, tLorig, mMuMinusSigma, [0 0],'Color','black');
        colormap(cmap);
        shading interp
        set(cb,'FontSize',nFontSize);
    end
    plot( fLogPrev(IndicesC1Prev), LPrev(IndicesC1Prev), 'bo', 'LineWidth',1.5 );
    plot( fLogPrev(IndicesC2Prev), LPrev(IndicesC2Prev), 'r+', 'LineWidth',1.5 );
    plot( log2(ThisF), ThisL,'kp','LineWidth',1.5,'MarkerSize',10);
    xlim([log2(nMinF) log2(nMaxF)]);
    ylim([min(Lgrid) max(Lgrid)]);
    text(log2(nMinF)+0.2, max(Lgrid) - 8, num2str(i), 'FontSize', nFontSize );
    l = legend('next tone','''yes'' answers','''no'' answers','Location','NE');
    xlabel('Frequency [Hz]');
    ylabel(['Hearing loss [dB]']);    
    set(gca,'XTick',log2([125 250 500 1000 2000 4000 8000]),'XTickLabel',[125 250 500 1000 2000 4000 8000]);
    set(gca,'FontSize',nFontSize);
    set(l,'FontSize',nFontSize);
    print(['out/png/' strFile(5:24) ' ' num2str(i,'%03.0f') ' p'], '-dpng', '-r0');
    
    if ( ThisI < 1 )
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
        mMuPlusSigma = reshape(a+b, size(tforig));
        mMuMinusSigma = reshape(a-b, size(tforig));
        H1 = BinaryEntropy( GaussianCDFDelta( la ./ sqrt( lb + 1 ), delta ) );                 % eq. 3
        H2 = ExpectedEntropy( la, lb, delta );
        I = H1 - H2; 
    end
    
    figure;
    plot( 10^10, 10^10,'kp','LineWidth',1.5,'MarkerSize',10);
    hold on;
    plot( 10^10, 10^10, 'bo', 'LineWidth',1.5 );
    plot( 10^10, 10^10, 'r+', 'LineWidth',1.5 );
    if (bShowGP)
        pcolor(tforig, tLorig, reshape(I, size(tforig)) )  
        hold on;
        cb = colorbar;
        caxis([0 1])
        ylabel(cb,'Information [bit]');
        [c h] = contour(tforig, tLorig, mYt, [0.5 0.5],'Color','black');
        set(h, 'LineWidth', 2)
        contour(tforig, tLorig, mMuPlusSigma, [0 0],'Color','black');
        contour(tforig, tLorig, mMuMinusSigma, [0 0],'Color','black');
        colormap(cmap);
        shading interp
        set(cb,'FontSize',nFontSize);
    end
    plot( fLog(IndicesC1), L(IndicesC1), 'bo', 'LineWidth',1.5 );
    plot( fLog(IndicesC2), L(IndicesC2), 'r+', 'LineWidth',1.5 );
    xlim([log2(nMinF) log2(nMaxF)]);
    ylim([min(Lgrid) max(Lgrid)]);
    text(log2(nMinF)+0.2, max(Lgrid) - 8, num2str(i), 'FontSize', nFontSize );
    l = legend('next tone','''yes'' answers','''no'' answers','Location','NE');
    xlabel('Frequency [Hz]');
    ylabel(['Hearing loss [dB]']);    
    set(gca,'XTick',log2([125 250 500 1000 2000 4000 8000]),'XTickLabel',[125 250 500 1000 2000 4000 8000]);
    set(gca,'FontSize',nFontSize);
    set(l,'FontSize',nFontSize);
    print(['out/png/' strFile(5:24) ' ' num2str(i,'%03.0f') ' r'], '-dpng', '-r0');
    close all
    
    if ( ThisI == 1 && M(i+1,5) < 1 )
        bShowGP = 1;
    end
    
end

shuttleVideo = VideoReader('shuttle.avi');

imageNames = dir(fullfile(pwd,'out/png',[strFile(5:24) '*.png']));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile(pwd,'out/vid',[strFile(5:24) '.avi']));
outputVideo.FrameRate = shuttleVideo.FrameRate;
outputVideo.FrameRate = 3;
open(outputVideo)

for ii = 1:length(imageNames)
   img = imread(fullfile(pwd,'out/png',imageNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)