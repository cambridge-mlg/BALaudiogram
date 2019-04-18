function plotGPSimple( lp, fmu, fs2, I, tforig, tLorig, vFPresented, vLPresented, vAnswers, fNext, LNext )

nFontSize = 14;
set(gca,'FontSize',nFontSize);

cR = linspace(1,1,100);
cG = linspace(1,0.08,100);
cB = linspace(1,0.58,100);
cmap = [cR' cG' cB'];

mYt = reshape(exp(lp), size(tforig));

IndicesC1 = nonzeros( (1:length(vAnswers)) .* (vAnswers == 1) );   % Indices which elements of c are 1
% IndicesC2 = nonzeros( (1:length(vAnswers)) .* ~vAnswers );
IndicesC2 = nonzeros( (1:length(vAnswers)) .* (vAnswers ~= 1) );
hold off;
pcolor(tforig, tLorig, reshape(I, size(tforig)) );
% pcolor(tforig, tLorig, mYt )
colormap(cmap);
shading interp
hold on;
plot( log2(vFPresented(IndicesC1)), vLPresented(IndicesC1), 'bo','LineWidth',1.5,'MarkerSize',10 );
plot( log2(vFPresented(IndicesC2)), vLPresented(IndicesC2), 'r+','LineWidth',1.5,'MarkerSize',10 );
    cb = colorbar;
    caxis([0 1])
    ylabel(cb,'Mutual information / bits','FontSize',nFontSize);
[~, h] = contour(tforig, tLorig, mYt, [0.5 0.5],'Color','black');
set(h, 'LineWidth', 2)
if nargin > 9
    plot( log2(fNext), LNext,'kp','LineWidth',1.5,'MarkerSize',10);
end
set(gca,'FontSize',nFontSize);
set(cb,'FontSize',14);
set(gca,'XTick',log2([125 250 500 1000 2000 4000 8000]),'XTickLabel',[125 250 500 1000 2000 4000 8000]);
    
% xlim([min(tforig(:)) max(tforig(:))]);
% ylim([min(tLorig(:)) max(tLorig(:))]);
% xlim([0 20])
% ylim([-100 150])
xlabel('Frequency / Hz ');
ylabel('Level / dB HL');
text(log2(max(vFPresented))-0.2,-5,num2str(length(vAnswers)),'FontSize',nFontSize,'HorizontalAlignment','right');