function varargout = audiogram(varargin)
%  Yes/No audiogram using GP and maximising mutual information
%  Copyright by Josef Schlittenlacher, Richard Turner and B.C.J Moore
%  Copyright for GP code: see file headers in gpml folder and/or http://www.gaussianprocess.org
%
%  for subject testing, set bPlot to 0 in getNextAudiogramTrialGP, line 3
%  to follow the process, set it to 1

% Last Modified by GUIDE v2.5 04-May-2016 14:43:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @audiogram_OpeningFcn, ...
                   'gui_OutputFcn',  @audiogram_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before audiogram is made visible.
function audiogram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to audiogram (see VARARGIN)

% Choose default command line output for audiogram
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes audiogram wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = audiogram_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

set(hObject, 'units','normalized','outerposition',[0 0 1 1]); % full screen

addpath(genpath('../gpml-matlab-v3.6-2015-07-07'));

TextFileToEdit( 'instructions_audiogram.txt', handles.edit1 );

% read configuration file
[handles.strOutputFolder, handles.nTrialsMax, handles.dInformationStop, handles.LMaxLevelSPL, handles.Fs, handles.InterTrial, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, nRiseFall, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.nSilentTrials] = readConfigAudiogram();
handles.dRiseFall        = nRiseFall / 1000;
guidata(hObject,handles);
vSilentTrials            = randperm( handles.nTrialsMax - 12 ) + 10; % trial numbers after which catch trials appear
handles.vSilentTrials    = vSilentTrials(1:(handles.nSilentTrials));
handles.bLastTrialSilent = 0;

strSubject = getSubjectCode();

handles.nTrialsAlreadyRun = 0;
handles.vFPresented = []; % all frequencies presented so far
handles.vLPresented = []; % all corresponding levels
handles.vAnswers = []; % responses (0|1) of these trials
handles.vInformation = [1];
handles.mHyperParameters = [0 0 0 0 0];
handles.eInitial = 2; % 2 -> 1 kHz test, 1 -> audiometric f test, 0 -> GP test
handles.nNextF = 1000; % first trial at 1 kHz and 60 dB HL
handles.nNextL = 60;
handles.strSubject = strSubject;

set(handles.axes1,'Visible','Off');

guidata(hObject,handles);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbYes.
function pbYes_Callback(hObject, eventdata, handles)
% hObject    handle to pbYes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% evaluate current trial and run the next trial or finish test
% three cases regarding catch trial and normal trial (there are never two
% silent trials in a row)

set(handles.pbYes,'Visible','off');
set(handles.pbNo,'Visible','off');
guidata(hObject,handles);
drawnow

if ( handles.bLastTrialSilent == 1 ) % evaluate silent, run normal
    handles.bLastTrialSilent = 0;
    evaluateSilentLapse( length(handles.vAnswers), 1, handles.strSubject, handles.strEar, handles.strStartTime );
    [handles.nNextF, handles.nNextL, dInformation, handles.eInitial, vHyperParameters] = chooseNextAudiogramTrial( handles.eInitial, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.LMaxLevelSPL, handles.strSubject, handles.strEar, handles.strStartTime );
    handles.vInformation = [handles.vInformation dInformation];
    handles.mHyperParameters = [handles.mHyperParameters; vHyperParameters];
    guidata(hObject,handles);
    if ( length( handles.vAnswers ) < handles.nTrialsMax )
        runAudiogramTrial( handles.nNextF, handles.nNextL, handles.Fs, handles.LMaxLevelSPL, handles.pbYes, handles.pbNo, handles.tIndicateSound, handles.edit1, handles.strEar, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, handles.dRiseFall );
    else
        saveAudiogram(handles.strOutputFolder, handles.strSubject, handles.strStartTime, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.strEar, handles.vInformation, handles.mHyperParameters, handles.vRT );
        set( handles.tFinished, 'Visible', 'on' );
    end
elseif ( handles.bLastTrialSilent == 0 && any( handles.vSilentTrials  == ( length( handles.vAnswers ) ) + 1 ) ) % evaluate normal, run silent  
    nRT = getTimeMeasurement();
    pause(0.5);
    handles.vRT = [handles.vRT nRT];
    handles.bLastTrialSilent = 1;
    handles.vAnswers = [handles.vAnswers 1];
    handles.vLPresented = [handles.vLPresented handles.nNextL];
    handles.vFPresented = [handles.vFPresented handles.nNextF];
    guidata(hObject,handles);
    runAudiogramTrial( handles.Fs/2, -inf, handles.Fs, handles.LMaxLevelSPL, handles.pbYes, handles.pbNo, handles.tIndicateSound, handles.edit1, handles.strEar, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, handles.dRiseFall );
        
else % evaluate normal, run normal; there are never two silent without a normal in-between  
    nRT = getTimeMeasurement();
    handles.vRT = [handles.vRT nRT];
    handles.vAnswers = [handles.vAnswers 1];
    handles.vLPresented = [handles.vLPresented handles.nNextL];
    handles.vFPresented = [handles.vFPresented handles.nNextF];
    [handles.nNextF, handles.nNextL, dInformation, handles.eInitial, vHyperParameters] = chooseNextAudiogramTrial( handles.eInitial, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.LMaxLevelSPL, handles.strSubject, handles.strEar, handles.strStartTime );
    handles.vInformation = [handles.vInformation dInformation];
    handles.mHyperParameters = [handles.mHyperParameters; vHyperParameters];
    guidata(hObject,handles);
    if ( length( handles.vAnswers ) < handles.nTrialsMax ) 
        runAudiogramTrial( handles.nNextF, handles.nNextL, handles.Fs, handles.LMaxLevelSPL, handles.pbYes, handles.pbNo, handles.tIndicateSound, handles.edit1, handles.strEar, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, handles.dRiseFall );
    else
        saveAudiogram(handles.strOutputFolder, handles.strSubject, handles.strStartTime, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.strEar, handles.vInformation, handles.mHyperParameters, handles.vRT  );
        set( handles.tFinished, 'Visible', 'on' );
    end

end


% --- Executes on button press in pbNo.
function pbNo_Callback(hObject, eventdata, handles)
% hObject    handle to pbNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% copied from pbYes, but store 0 instead of 1 as response

set(handles.pbYes,'Visible','off');
set(handles.pbNo,'Visible','off');
guidata(hObject,handles);
drawnow

if ( handles.bLastTrialSilent == 1 ) % evaluate silent, run normal
    handles.bLastTrialSilent = 0;
    
    getTimeMeasurement();
    evaluateSilentLapse( length(handles.vAnswers), 0, handles.strSubject, handles.strEar, handles.strStartTime );
    [handles.nNextF, handles.nNextL, dInformation, handles.eInitial, vHyperParameters] = chooseNextAudiogramTrial( handles.eInitial, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.LMaxLevelSPL, handles.strSubject, handles.strEar, handles.strStartTime );
    handles.vInformation = [handles.vInformation dInformation];
    handles.mHyperParameters = [handles.mHyperParameters; vHyperParameters];
    guidata(hObject,handles);
    if ( length( handles.vAnswers ) < handles.nTrialsMax )   
        runAudiogramTrial( handles.nNextF, handles.nNextL, handles.Fs, handles.LMaxLevelSPL, handles.pbYes, handles.pbNo, handles.tIndicateSound, handles.edit1, handles.strEar, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, handles.dRiseFall );
    else
        saveAudiogram(handles.strOutputFolder, handles.strSubject, handles.strStartTime, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.strEar, handles.vInformation, handles.mHyperParameters, handles.vRT  );
        set( handles.tFinished, 'Visible', 'on' );
    end
elseif ( handles.bLastTrialSilent == 0 && any( handles.vSilentTrials  == ( length( handles.vAnswers ) ) + 1 ) ) % evaluate normal, run silent   
    nRT = getTimeMeasurement();
    pause(0.5);
    handles.vRT = [handles.vRT nRT];
    handles.bLastTrialSilent = 1;
    handles.vAnswers = [handles.vAnswers 0];
    handles.vLPresented = [handles.vLPresented handles.nNextL];
    handles.vFPresented = [handles.vFPresented handles.nNextF];
    guidata(hObject,handles);
    runAudiogramTrial( handles.Fs/2, -inf, handles.Fs, handles.LMaxLevelSPL, handles.pbYes, handles.pbNo, handles.tIndicateSound, handles.edit1, handles.strEar, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, handles.dRiseFall );
else % evaluate normal, run normal; there are never two silent without a normal in-between
    
    nRT = getTimeMeasurement();
    handles.vRT = [handles.vRT nRT];
    handles.vAnswers = [handles.vAnswers 0];
    handles.vLPresented = [handles.vLPresented handles.nNextL];
    handles.vFPresented = [handles.vFPresented handles.nNextF];
    [handles.nNextF, handles.nNextL, dInformation, handles.eInitial, vHyperParameters] = chooseNextAudiogramTrial( handles.eInitial, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.LMaxLevelSPL, handles.strSubject, handles.strEar, handles.strStartTime );
    handles.vInformation = [handles.vInformation dInformation];
    handles.mHyperParameters = [handles.mHyperParameters; vHyperParameters];
    guidata(hObject,handles);
    if ( length( handles.vAnswers ) < handles.nTrialsMax )      
        runAudiogramTrial( handles.nNextF, handles.nNextL, handles.Fs, handles.LMaxLevelSPL, handles.pbYes, handles.pbNo, handles.tIndicateSound, handles.edit1, handles.strEar, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, handles.dRiseFall );
    else
        saveAudiogram(handles.strOutputFolder, handles.strSubject, handles.strStartTime, handles.vFPresented, handles.vLPresented, handles.vAnswers, handles.nMinF, handles.nMaxF, handles.dStepSize, handles.strEar, handles.vInformation, handles.mHyperParameters, handles.vRT  );
        set( handles.tFinished, 'Visible', 'on' );
    end

end


% --- Executes on button press in pbStart.
function pbStart_Callback(hObject, eventdata, handles)
% hObject    handle to pbStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set( handles.pbStart,'visible', 'off' );
set( handles.tIndicateSound,'visible', 'off' );
handles.edit1.String = 'Did you hear the tone?';
handles.edit1.HorizontalAlignment = 'center';

handles.strStartTime = char(datetime('now','Format','yMMdd HHmmss'));
handles.vRT = []; % response times

if (handles.rbLeft.Value)
    handles.strEar = 'L';
else
    handles.strEar = 'R';
end

guidata(hObject,handles);

set( handles.rbLeft,'visible', 'off' );
set( handles.rbRight,'visible', 'off' );

guidata(hObject,handles);
set(handles.pbNo,'Visible', 'off');
set(handles.pbYes,'Visible', 'off');
set(handles.edit1,'Visible', 'off');
set(handles.tIndicateSound,'Visible', 'off');
pause(0.5);

%run first trial
runAudiogramTrial( handles.nNextF, handles.nNextL, handles.Fs, handles.LMaxLevelSPL, handles.pbYes, handles.pbNo, handles.tIndicateSound, handles.edit1, handles.strEar, handles.nPulses, handles.nPulseDuration, handles.nPulsePause, handles.dRiseFall );


% --- Executes on button press in rbLeft.
function rbLeft_Callback(hObject, eventdata, handles)
% hObject    handle to rbLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbLeft

set(handles.rbLeft,'Value',1);
set(handles.rbRight,'Value',0);

% --- Executes on button press in rbRight.
function rbRight_Callback(hObject, eventdata, handles)
% hObject    handle to rbRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRight

set(handles.rbLeft,'Value',0);
set(handles.rbRight,'Value',1);
