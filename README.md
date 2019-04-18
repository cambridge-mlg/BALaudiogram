# BALaudiogram
A Bayesian active-learning procedure to obtain an audiogram, as described in Schlittenlacher et al. (2018, asa.scitation.org/doi/abs/10.1121/1.5047436). Matlab/Octave. Uses the GPML Toolbox (www.gaussianprocess.org/gpml), and is an application of the classification procedure described by Houlsby et al. (2011, https://arxiv.org/pdf/1112.5745)

To get the code running you need Matlab and the GPML toolbox, version 3.6 from gaussianprocess.org. Direct download link: http://gaussianprocess.org/gpml/code/matlab/release/gpml-matlab-v3.6-2015-07-07.zip
Extract the audiogram zip file and the GPML toolbox so that the folders ‘audiogram’ and ‘gpml-matlab-v3.6-2015-07-07’ are in the same folder.

Before starting, you need to adjust the file FlatAtEardrumCorrection.m to incorporate the transfer function of your headphones to the eardrum. Depending on your method for doing this, you may also need to change the minimum audible pressure, which is defined in MAP_MG2007.m
For the results in our JASA paper, ISO 389-8 was used. The files here are based on measurements with KEMAR (i.e. not compliant with ISO 389-8, though a good choice for other experiments in our opinion).

You may want to change the number of trials, catch trials, pulses per sound, pulse duration, etc. Do this in configAudiogram.txt. configAudiogram_Explanation.txt gives short explanations for each line.

To start an audiogram, run ‘audiogram’. You will be prompted to enter a subject name and choose the ear before clicking the start button.
The results are stored in several ways. A mat-file is stored in ‘out/mat’ and updated after each trial. After the experiment, a text file with all trials, text files with the estimated threshold (one with date and time and one without) and a text file with the results for the catch trials are written to folder ‘out’.
The columns of ‘… all trials.txt’ are: Trial number, frequency (Hz), level (dB HL), response (1 = Yes, 0 = No), expected information of that trial (bit, set to 1 for trials of the initial grid), hyperparameters of the Gaussian Process (set to 0 for trials of the initial grid, 5 columns), and response time (in seconds).
The results for the catch trials are given in two columns in ‘… lapse silent trials’. The first column shows the trial number after which the catch trial occurred, the second column the response (0 = no = correct).
You can use the files starting ‘analyze’ to generate a figure of the results or even a video. 

The basic procedural flow is as follows (see also Function flow overview.txt)
audiogram.m and audiogram.fig contain the GUI. The experiment is prepared and started in functions audiogram_OutputFcn and pbStart, and returns to the GUI after each trial, waiting for pbYes or pbNo (Sorry that these became a bit messy after adding silent trials and response times). These two functions determine the parameters for the next trial with chooseNextAudiogramTrial and present the sound with runAudiogramTrial.
chooseNextAudiogramTrial will call one of the getNextAudiogramTrial… functions. Those ending 1kHz, BorderFrequency and Octaves are if-else constructs for the initial grid, that ending GP uses a Gaussian Process and mutual information.
For implementing other sounds, you need to change genAudiogramSound and also change what happens for the catch trials (in pbYes and pbNo). genAudiogramSound returns a waveform so the code is highly adaptable.
