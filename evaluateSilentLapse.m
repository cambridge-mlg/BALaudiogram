function evaluateSilentLapse( nTrial, nAnswer, strSubject, strEar, strStartTime )

% store response to a silent trial

fid = fopen(['out/' strSubject ' ' strEar ' ' strStartTime ' lapse silent trials.txt'],'a+');
fprintf(fid,'%5.0f\t%5.0f\n',nTrial,nAnswer);
fclose(fid);