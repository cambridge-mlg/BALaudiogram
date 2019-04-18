function [strOutputFolder, nTrialsMax, dInformationStop, LMaxLevelSPL, Fs, InterTrial, nPulses, nPulseDuration, nPulsePause, nRiseFall, nMinF, nMaxF, dStepSize, nSilentTrials, nFirstFrequency, nFirstLevel, bFullScreen, bPlot] = readConfigAudiogram()

% read the configuration file and store the variables
% see configAudiogram.txt and configAudiogram_Explanation.txt

fid = fopen('configAudiogram.txt');
strOutputFolder = char( fgetl(fid) );
nTrialsMax = str2double( fgetl(fid) );
dInformationStop = str2double( fgetl(fid) );
LMaxLevelSPL = str2double( fgetl(fid) );
Fs = str2double( fgetl(fid) );
InterTrial = str2double( fgetl(fid) );
nPulses = str2double( fgetl(fid) );
nPulseDuration = str2double( fgetl(fid) );
nPulsePause = str2double( fgetl(fid) );
nRiseFall = str2double( fgetl(fid) );
nMinF = str2double( fgetl(fid) );
nMaxF = str2double( fgetl(fid) );
dStepSize = str2double( fgetl(fid) );
nSilentTrials = str2double( fgetl(fid) );
nFirstFrequency = str2double( fgetl(fid) );
nFirstLevel = str2double( fgetl(fid) );
bFullScreen = str2double( fgetl(fid) );
bPlot = str2double( fgetl(fid) );
fclose(fid);