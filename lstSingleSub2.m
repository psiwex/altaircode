

%tic;
fName='OSU-00001-04B-01-ERN.bdf';
subName='OSU-00002-04B-01-LST';
savePath='.';
loadPath='.';
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
binlister_loadpath='C:\Users\John\Documents\MATLAB\soarEtl\currentSoar\LstBinlister.txt';
binListerPath=binlister_loadpath;
savePathRunICA='.';
% winLength=1;
% f3=strcat(subName, '.log');
% lst = readtable(f3,'NumHeaderLines',5,ReadRowNames=true);
% llst=table2cell(lst);

    ALLERP = buildERPstruct([]);
CURRENTERP = 0;

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;



EEG = pop_biosig([subName '.bdf']);

EEG = pop_editset(EEG, 'setname', [ '_Raw']);

EEG = pop_saveset( EEG, 'filename',[ '_Raw.set'],...
    'filepath',savePath);



eeglab redraw;

  % 1. load RAW data
  clear EEG;
    EEG = pop_loadset('filename',[ '_Raw.set'],...
        'filepath',loadPath);
    eventTemplate=EEG.event;
    save('eventTemplate.mat','eventTemplate');
    % 2. edit channels
    % BioSemi: Remove PA1/2, EKG1/2, STG1/2, and M1/M2 channels, relabel externals for locations
    EEG = pop_eegchanoperator( EEG, {  'nch1 = ch1 - ( 0 ) Label Fp1',  'nch2 = ch2 - ( 0 ) Label AF3',  'nch3 = ch3 - ( 0 ) Label F7',  'nch4 = ch4 - ( 0 ) Label F3',  'nch5 = ch5 - ( 0 ) Label FC1',  'nch6 = ch6 - ( 0 ) Label FC5',  'nch7 = ch7 - ( 0 ) Label T7',  'nch8 = ch8 - ( 0 ) Label C3',  'nch9 = ch9 - ( 0 ) Label CP1',  'nch10 = ch10 - ( 0 ) Label CP5',  'nch11 = ch11 - ( 0 ) Label P7',  'nch12 = ch12 - ( 0 ) Label P3',  'nch13 = ch13 - ( 0 ) Label Pz',  'nch14 = ch14 - ( 0 ) Label PO3',  'nch15 = ch15 - ( 0 ) Label O1',  'nch16 = ch16 - ( 0 ) Label Oz',  'nch17 = ch17 - ( 0 ) Label O2',  'nch18 = ch18 - ( 0 ) Label PO4',  'nch19 = ch19 - ( 0 ) Label P4',  'nch20 = ch20 - ( 0 ) Label P8',  'nch21 = ch21 - ( 0 ) Label CP6',  'nch22 = ch22 - ( 0 ) Label CP2',  'nch23 = ch23 - ( 0 ) Label C4',  'nch24 = ch24 - ( 0 ) Label T8',  'nch25 = ch25 - ( 0 ) Label FC6',  'nch26 = ch26 - ( 0 ) Label FC2',  'nch27 = ch27 - ( 0 ) Label F4',  'nch28 = ch28 - ( 0 ) Label F8',  'nch29 = ch29 - ( 0 ) Label AF4',  'nch30 = ch30 - ( 0 ) Label Fp2',  'nch31 = ch31 - ( 0 ) Label Fz',  'nch32 = ch32 - ( 0 ) Label Cz',  'nch33 = ch45 - ( 0 ) Label FCz',  'nch34 = ch46 - ( 0 ) Label Iz',  'nch35 = ch39 - ( 0 ) Label SO2',  'nch36 = ch40 - ( 0 ) Label IO2',  'nch37 = ch41 - ( 0 ) Label LO2',  'nch38 = ch42 - ( 0 ) Label LO1',  'nch39 = ch43 - ( 0 ) Label M1',  'nch40 = ch44 - ( 0 ) Label M2'} , 'ErrorMsg', 'popup', 'Warning', 'off' );    

    % 3. Resample data PROPERLY, For SIFT to ease antialiasing filter slope, see code from Makoto: 
        % https://sccn.ucsd.edu/wiki/Makoto%27s_useful_EEGLAB_code
        % https://eeglab.org/others/Firfilt_FAQ.html#Q._For_Granger_Causality_analysis.2C_what_filter_should_be_used.3F_.2804.2F26.2F2018_Updated.29
    % EEG = pop_resample(EEG, 250, 0.8, 0.4);  % NeuroScan
    EEG = pop_resample(EEG, 256, 0.8, 0.4); % BioSemi

    % 5. Use PREP to subtract line noise UNFILTERED (specifically designed for this): http://vislab.github.io/EEG-Clean-Tools/
        % code from Makoto: https://sccn.ucsd.edu/wiki/Makoto%27s_useful_EEGLAB_code
        % TAKES A WHILE
    signal = struct('data', EEG.data, 'srate', EEG.srate);
    lineNoiseIn = struct('lineNoiseMethod', 'clean', ...
                             'lineNoiseChannels', 1:EEG.nbchan,...
                             'Fs', EEG.srate, ...
                             'lineFrequencies', [60 120 180 240],...
                             'p', 0.01, ...
                             'fScanBandWidth', 2, ...
                             'taperBandWidth', 2, ...
                             'taperWindowSize', 4, ...
                             'taperWindowStep', 1, ...
                             'tau', 100, ...
                             'pad', 2, ...
                             'fPassBand', [0 EEG.srate/2], ...
                             'maximumIterations', 10);
    [clnOutput, lineNoiseOut] = cleanLineNoise(signal, lineNoiseIn);
    EEG.data = clnOutput.data;
    
    % 4. Load channel locations
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;

    % 4. Save data here as _ChOpResamp256PREP,” these will get ICA weights later
    EEG = pop_editset(EEG, 'setname', [ '_ChOpResamp256PREP']);
    EEG = pop_saveset( EEG, 'filename',[ '_ChOpResamp256PREP.set'],...
         'filepath',savePath);
        eeglab redraw;


        % JG 1/15/2022
% 3ReadyForICA Script: 
% 1. Loads unfiltered .set file from 2PREP.
% 2. Highpass filter 1 Hz.
% 3. Remove external sensors.
% 4. Mark and create a list of bad scalp sensors using clean_rawdata.
% 5. Repeat steps 1-4 for external sensors.
% 6. Finally, repeat steps 1-2 and simply remove the list of bad scalp/external sensors.
% 7. Wipe all events from data by loading/applying eventTemplate.mat.
% 8. Artifact reject in continuous data using continuousartdet.
% 9. Save .set file ready for ICA.

%%%%% LST DATA



%loadPath = 'E:\BiAffectTesting\Datasets\2PREP\LST\';
%savePath = 'E:\BiAffectTesting\Datasets\3ReadyForICA\LST\';
%eventTemplatePath = 'E:\BiAffectTesting\Scripts\Pre_Processing\eventTemplate.mat';
% % channelLocationFile = 'C:\Users\James\Documents\MatLab_Programs\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
% channelLocationFile = 'C:\Users\glaze\Documents\MatLabPrograms\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';

% Subject list
%subName = {'CCS001_EEG1_LST', 	'CCS001_EEG2_LST', 	'CCS002_EEG1_LST', 	'CCS002_EEG2_LST', 	'CCS003_EEG1_LST', 	'CCS003_EEG2_LST'};

eTemplate=load('eventTemplate.mat');
eventTemplate=eTemplate.eventTemplate;
%clear EEG;
    % 1. load _ChOpResamp256PREP" to continue preprocessing
    EEG = pop_loadset('filename',['_ChOpResamp256PREP.set'],...
        'filepath',loadPath);
  
    % 4. High pass zero phase 1 Hz cutoff FIR filter for ICA, Note: the transition band is automatically adjusted so that it always ends at DC, as recommended:
        % https://eeglab.org/others/Firfilt_FAQ.html#Q._For_Granger_Causality_analysis.2C_what_filter_should_be_used.3F_.2804.2F26.2F2018_Updated.29)
        % code from Makoto: https://sccn.ucsd.edu/wiki/Makoto%27s_useful_EEGLAB_code
        % Step 4: High-pass filter the data at 1-Hz. Note that EEGLAB uses pass-band edge, therefore 1/2 = 0.5 Hz.
        % CAUSALITY NOTE: consider causal filters etc. later ONLY FOR USE WITH Granger Causality analysis, 
   % EEG = pop_eegfiltnew(EEG, 1, 0, 1650, 0, [], 0);
EEG = pop_eegfiltnew(EEG, 1, 0, [], 0, [], 0);
% 	% Rereference to MASTOIDS, remove mastoids
    EEG = pop_reref( EEG, [35, 36]);
    eeglab redraw;
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
    % 5. Use EEGLAB clean_rawdata (or PREP) to remove bad channels
    % Bad Channel Rejection using: Clean_rawdata method eeglab
    % first delete external sensors, retain scalp channels
    EEG = pop_eegchanoperator( EEG, {  'nch1 = ch1 - ( 0 ) Label Fp1',  'nch2 = ch2 - ( 0 ) Label AF3',  'nch3 = ch3 - ( 0 ) Label F7',  'nch4 = ch4 - ( 0 ) Label F3',  'nch5 = ch5 - ( 0 ) Label FC1',  'nch6 = ch6 - ( 0 ) Label FC5',  'nch7 = ch7 - ( 0 ) Label T7',  'nch8 = ch8 - ( 0 ) Label C3',  'nch9 = ch9 - ( 0 ) Label CP1',  'nch10 = ch10 - ( 0 ) Label CP5',  'nch11 = ch11 - ( 0 ) Label P7',  'nch12 = ch12 - ( 0 ) Label P3',  'nch13 = ch13 - ( 0 ) Label Pz',  'nch14 = ch14 - ( 0 ) Label PO3',  'nch15 = ch15 - ( 0 ) Label O1',  'nch16 = ch16 - ( 0 ) Label Oz',  'nch17 = ch17 - ( 0 ) Label O2',  'nch18 = ch18 - ( 0 ) Label PO4',  'nch19 = ch19 - ( 0 ) Label P4',  'nch20 = ch20 - ( 0 ) Label P8',  'nch21 = ch21 - ( 0 ) Label CP6',  'nch22 = ch22 - ( 0 ) Label CP2',  'nch23 = ch23 - ( 0 ) Label C4',  'nch24 = ch24 - ( 0 ) Label T8',  'nch25 = ch25 - ( 0 ) Label FC6',  'nch26 = ch26 - ( 0 ) Label FC2',  'nch27 = ch27 - ( 0 ) Label F4',  'nch28 = ch28 - ( 0 ) Label F8',  'nch29 = ch29 - ( 0 ) Label AF4',  'nch30 = ch30 - ( 0 ) Label Fp2',  'nch31 = ch31 - ( 0 ) Label Fz',  'nch32 = ch32 - ( 0 ) Label Cz',  'nch33 = ch33 - ( 0 ) Label FCz',  'nch34 = ch34 - ( 0 ) Label Iz'} , 'ErrorMsg', 'popup', 'Warning', 'off' );    
    
    % reload channel locations
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
    
    % use clean_rawdata only for bad channel rejection, these parameters are tuned for SCALP electrodes
        % NOTE: very conservative ChannelCriterionMaxBadTime here to prepare data for ICA: If channel is abnormal for over 10% of data (.10)
    EEG = pop_clean_rawdata(EEG,...
        'FlatlineCriterion',5,'ChannelCriterion',0.70,'LineNoiseCriterion',8,'ChannelCriterionMaxBadTime', .10, ...
        'Highpass','off' ,'BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    eeglab redraw;

    %add scalp channels to list of channels after channel rejection
    trimChans = {}
    for channel = 1:EEG.nbchan
        trimChans{end+1} = EEG.chanlocs(channel).labels;
    end
    clear EEG;
    % 1. load _ChOpResamp256PREP" once again to perform separate rejection on external sensors
    EEG = pop_loadset('filename',['_ChOpResamp256PREP.set'],...
        'filepath',loadPath);
    
    % same 1 Hz high pass: these high passes are necessary to detect bad channels
    EEG = pop_eegfiltnew(EEG, 1, 0, [], 0, [], 0);
    
    % delete scalp channels, retain external channels
        % NOTE: NO CHANNEL LOOKUP: doesn't work with chan lookup for exgs don't give it spatial information because only four of them
    EEG = pop_eegchanoperator( EEG, {  'nch1 = ch35 - ( 0 ) Label SO2',  'nch2 = ch36 - ( 0 ) Label IO2',  'nch3 = ch37 - ( 0 ) Label LO2',  'nch4 = ch38 - ( 0 ) Label LO1',  'nch5 = ch39 - ( 0 ) Label M1',  'nch6 = ch40 - ( 0 ) Label M2'} , 'ErrorMsg', 'popup', 'Warning', 'off' );    
    eeglab redraw;

    % use clean_rawdata only for bad channel rejection, these parameters are tuned for EOG electrodes
        % NOTE: The changed correlation parameter to .1 (exgs shouldn't really be correlated) and linenoisecriterion to 16 loose
    EEG = pop_clean_rawdata(EEG,...
            'FlatlineCriterion',5,'ChannelCriterion',0.10,'LineNoiseCriterion',16,...
            'Highpass','off' ,'BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    eeglab redraw;
   
    % add EXG channels to list of channels after channel rejection
s1=max(EEG.nbchan);
    for channel = 1:s1
        trimChans{end+1} = EEG.chanlocs(channel).labels;
    end

    % finally load the _ChOpResamp256PREP file one last time, this will be the final file that we will remove both scalp and EXG channels from
    clear EEG;
    EEG = pop_loadset('filename',['_ChOpResamp256PREP.set'],...
        'filepath',loadPath);
    
    % same 1 Hz high pass, this time we apply 1 Hz high pass to prepare data for ICA
	% see Makoto pipeline for empirical support that:
		% 1. 1 Hz high pass improves stationarity of data which improves ICA and 
		% 2. Taking ICA weights extracted from a 1 Hz high pass dataset and applying them to unfiltered dataset is appropriate
    EEG = pop_eegfiltnew(EEG, 1, 0, [], 0, [], 0);
    
    %get list of channels before channel rejection
    allChans = {}
    for channel = 1:EEG.nbchan
        allChans{end+1} = EEG.chanlocs(channel).labels;
    end

    %get list of bad/rejected channels
    badChansList = {};
    for channel = 1:length(allChans)
%         badChan = contains(trimChans, allChans(channel))
        badChan = strcmp(trimChans, allChans(channel));
        if sum(badChan) == 0
            % EEG = pop_select( EEG, 'nochannel',{allChans{channel}});
            badChansList{end+1} = allChans{channel};
        end
    end
    eeglab redraw;
    
    % FINALLY, remove the bad channels, and you're done with this method!
    for channel = 1:length(badChansList)
        EEG = pop_select( EEG, 'nochannel',{badChansList{channel}});
    end
    eeglab redraw;

    % Load channel locations again
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    
    % 6. Use ERPLAB (OR EEGLAB clean_rawdata ASR) to remove bad continuous data segments
    % first determine how many external EOG electrodes were removed as bad (if any) so we don't include them in continuous artifact rejection
    exgChanList = {'LO1', 'LO2', 'SO2', 'IO2', 'M1', 'M2'};
    totalExgChans = 0;
    for channel = 1:EEG.nbchan
        for exgChan = 1:length(exgChanList)
            if string(EEG.chanlocs(channel).labels) == exgChanList{exgChan}
                totalExgChans = totalExgChans + 1;
            end
        end
    end

	% wipe all event codes from dataset to make sure at least one code is present to that ERPLAB artifact rejection works
    EEG.event = eventTemplate;
    eeglab redraw;
	
    % ERPlab example to remove c.r.a.p. artifacts in continuous data, tuned for scalp electrodes going into ICA
	% see ERPLAB website
    EEG = pop_continuousartdet( EEG , 'ampth',  500, 'chanArray',  [1:EEG.nbchan-totalExgChans], 'colorseg', [ 1 0.9765 0.5294],...
        'forder',  100, 'numChanThreshold',  1, 'shortseg',  10, 'stepms',  250, 'threshType', 'peak-to-peak', 'winms',  500, 'winoffset',  50 );
	eeglab redraw;

    % Save data here as ready for ICA: _ChOpResampPREP_1HzHpRejChanData
    EEG = pop_editset(EEG, 'setname', ['_ChOpResamp256PREP_1HzHpRejChanData_ReadyForICA']);
    EEG = pop_saveset( EEG, 'filename',['_ChOpResamp256PREP_1HzHpRejChanData_ReadyForICA.set'],...
         'filepath',savePath);
  clear EEG;
    % 1. load _ChOpResamp256PREP" to continue preprocessing
    EEG = pop_loadset('filename',['_ChOpResamp256PREP.set'],...
        'filepath',loadPath);
  
    % 4. High pass zero phase 1 Hz cutoff FIR filter for ICA, Note: the transition band is automatically adjusted so that it always ends at DC, as recommended:
        % https://eeglab.org/others/Firfilt_FAQ.html#Q._For_Granger_Causality_analysis.2C_what_filter_should_be_used.3F_.2804.2F26.2F2018_Updated.29)
        % code from Makoto: https://sccn.ucsd.edu/wiki/Makoto%27s_useful_EEGLAB_code
        % Step 4: High-pass filter the data at 1-Hz. Note that EEGLAB uses pass-band edge, therefore 1/2 = 0.5 Hz.
        % CAUSALITY NOTE: consider causal filters etc. later ONLY FOR USE WITH Granger Causality analysis, 
    EEG = pop_eegfiltnew(EEG, 1, 0, [], 0, [], 0);

    % 5. Use EEGLAB clean_rawdata (or PREP) to remove bad channels
    % Bad Channel Rejection using: Clean_rawdata method eeglab
    % first delete external sensors, retain scalp channels
    EEG = pop_eegchanoperator( EEG, {  'nch1 = ch1 - ( 0 ) Label Fp1',  'nch2 = ch2 - ( 0 ) Label AF3',  'nch3 = ch3 - ( 0 ) Label F7',  'nch4 = ch4 - ( 0 ) Label F3',  'nch5 = ch5 - ( 0 ) Label FC1',  'nch6 = ch6 - ( 0 ) Label FC5',  'nch7 = ch7 - ( 0 ) Label T7',  'nch8 = ch8 - ( 0 ) Label C3',  'nch9 = ch9 - ( 0 ) Label CP1',  'nch10 = ch10 - ( 0 ) Label CP5',  'nch11 = ch11 - ( 0 ) Label P7',  'nch12 = ch12 - ( 0 ) Label P3',  'nch13 = ch13 - ( 0 ) Label Pz',  'nch14 = ch14 - ( 0 ) Label PO3',  'nch15 = ch15 - ( 0 ) Label O1',  'nch16 = ch16 - ( 0 ) Label Oz',  'nch17 = ch17 - ( 0 ) Label O2',  'nch18 = ch18 - ( 0 ) Label PO4',  'nch19 = ch19 - ( 0 ) Label P4',  'nch20 = ch20 - ( 0 ) Label P8',  'nch21 = ch21 - ( 0 ) Label CP6',  'nch22 = ch22 - ( 0 ) Label CP2',  'nch23 = ch23 - ( 0 ) Label C4',  'nch24 = ch24 - ( 0 ) Label T8',  'nch25 = ch25 - ( 0 ) Label FC6',  'nch26 = ch26 - ( 0 ) Label FC2',  'nch27 = ch27 - ( 0 ) Label F4',  'nch28 = ch28 - ( 0 ) Label F8',  'nch29 = ch29 - ( 0 ) Label AF4',  'nch30 = ch30 - ( 0 ) Label Fp2',  'nch31 = ch31 - ( 0 ) Label Fz',  'nch32 = ch32 - ( 0 ) Label Cz',  'nch33 = ch33 - ( 0 ) Label FCz',  'nch34 = ch34 - ( 0 ) Label Iz'} , 'ErrorMsg', 'popup', 'Warning', 'off' );    
    
    % reload channel locations
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
    
    % use clean_rawdata only for bad channel rejection, these parameters are tuned for SCALP electrodes
        % NOTE: very conservative ChannelCriterionMaxBadTime here to prepare data for ICA: If channel is abnormal for over 10% of data (.10)
    EEG = pop_clean_rawdata(EEG,...
        'FlatlineCriterion',5,'ChannelCriterion',0.70,'LineNoiseCriterion',8,'ChannelCriterionMaxBadTime', .10, ...
        'Highpass','off' ,'BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    eeglab redraw;

    %add scalp channels to list of channels after channel rejection
    trimChans = {}
    for channel = 1:EEG.nbchan
        trimChans{end+1} = EEG.chanlocs(channel).labels;
    end
    clear EEG;
    % 1. load _ChOpResamp256PREP" once again to perform separate rejection on external sensors
    EEG = pop_loadset('filename',['_ChOpResamp256PREP.set'],...
        'filepath',loadPath);
    
    % same 1 Hz high pass: these high passes are necessary to detect bad channels
    EEG = pop_eegfiltnew(EEG, 1, 0, [], 0, [], 0);
    
    % delete scalp channels, retain external channels
        % NOTE: NO CHANNEL LOOKUP: doesn't work with chan lookup for exgs don't give it spatial information because only four of them
    EEG = pop_eegchanoperator( EEG, {  'nch1 = ch35 - ( 0 ) Label SO2',  'nch2 = ch36 - ( 0 ) Label IO2',  'nch3 = ch37 - ( 0 ) Label LO2',  'nch4 = ch38 - ( 0 ) Label LO1',  'nch5 = ch39 - ( 0 ) Label M1',  'nch6 = ch40 - ( 0 ) Label M2'} , 'ErrorMsg', 'popup', 'Warning', 'off' );    
    eeglab redraw;

    % use clean_rawdata only for bad channel rejection, these parameters are tuned for EOG electrodes
        % NOTE: The changed correlation parameter to .1 (exgs shouldn't really be correlated) and linenoisecriterion to 16 loose
    EEG = pop_clean_rawdata(EEG,...
            'FlatlineCriterion',5,'ChannelCriterion',0.10,'LineNoiseCriterion',16,...
            'Highpass','off' ,'BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    eeglab redraw;

    % add EXG channels to list of channels after channel rejection
    for channel = 1:EEG.nbchan
        trimChans{end+1} = EEG.chanlocs(channel).labels;
    end
clear EEG;
    % finally load the _ChOpResamp256PREP file one last time, this will be the final file that we will remove both scalp and EXG channels from
    EEG = pop_loadset('filename',['_ChOpResamp256PREP.set'],...
        'filepath',loadPath);
    
    % same 1 Hz high pass, this time we apply 1 Hz high pass to prepare data for ICA
	% see Makoto pipeline for empirical support that:
		% 1. 1 Hz high pass improves stationarity of data which improves ICA and 
		% 2. Taking ICA weights extracted from a 1 Hz high pass dataset and applying them to unfiltered dataset is appropriate
    EEG = pop_eegfiltnew(EEG, 1, 0, [], 0, [], 0);
    
    %get list of channels before channel rejection
    allChans = {}
    for channel = 1:EEG.nbchan
        allChans{end+1} = EEG.chanlocs(channel).labels;
    end

    %get list of bad/rejected channels
    badChansList = {};
    for channel = 1:length(allChans)
%         badChan = contains(trimChans, allChans(channel))
        badChan = strcmp(trimChans, allChans(channel));
        if sum(badChan) == 0
            % EEG = pop_select( EEG, 'nochannel',{allChans{channel}});
            badChansList{end+1} = allChans{channel};
        end
    end
    eeglab redraw;
    
    % FINALLY, remove the bad channels, and you're done with this method!
    for channel = 1:length(badChansList)
        EEG = pop_select( EEG, 'nochannel',{badChansList{channel}});
    end
    eeglab redraw;

    % Load channel locations again
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    
    % 6. Use ERPLAB (OR EEGLAB clean_rawdata ASR) to remove bad continuous data segments
    % first determine how many external EOG electrodes were removed as bad (if any) so we don't include them in continuous artifact rejection
    exgChanList = {'LO1', 'LO2', 'SO2', 'IO2', 'M1', 'M2'};
    totalExgChans = 0;
    for channel = 1:EEG.nbchan
        for exgChan = 1:length(exgChanList)
            if string(EEG.chanlocs(channel).labels) == exgChanList{exgChan}
                totalExgChans = totalExgChans + 1;
            end
        end
    end

	% wipe all event codes from dataset to make sure at least one code is present to that ERPLAB artifact rejection works
    EEG.event = eventTemplate;
    eeglab redraw;
	
    % ERPlab example to remove c.r.a.p. artifacts in continuous data, tuned for scalp electrodes going into ICA
	% see ERPLAB website
    EEG = pop_continuousartdet( EEG , 'ampth',  500, 'chanArray',  [1:EEG.nbchan-totalExgChans], 'colorseg', [ 1 0.9765 0.5294],...
        'forder',  100, 'numChanThreshold',  1, 'shortseg',  10, 'stepms',  250, 'threshType', 'peak-to-peak', 'winms',  500, 'winoffset',  50 );
	eeglab redraw;

    % Save data here as ready for ICA: _ChOpResampPREP_1HzHpRejChanData
    EEG = pop_editset(EEG, 'setname', ['_ChOpResamp256PREP_1HzHpRejChanData_ReadyForICA']);
    EEG = pop_saveset( EEG, 'filename',['_ChOpResamp256PREP_1HzHpRejChanData_ReadyForICA.set'],...
         'filepath',savePath);
    EEG = pop_loadset('filename',['_ChOpResamp256PREP_1HzHpRejChanData_ReadyForICA.set'],...
        'filepath',loadPath);

    EEG = pop_runica(EEG, 'icatype','runica', 'extended',1);
    floatwrite(EEG.icaweights,['_ICAweight_ChOpResamp256PREP_1HzHpRejChanData.wts']);
    floatwrite(EEG.icasphere,['_ICAsphere_ChOpResamp256PREP_1HzHpRejChanData.sph']);

    EEG = pop_saveset( EEG, 'filename',['_ChOpResamp256PREP_1HzHpRejChanData_RunICA.set'],...
        'filepath',savePathRunICA);
  
clear EEG;
%toc;
    EEG = pop_loadset('filename',['_ChOpResamp256PREP.set'],...
        'filepath',loadPath);

    % just get scalp and mastoid channels
    EEG = pop_eegchanoperator( EEG, {  'nch1 = ch1 - ( 0 ) Label Fp1',  'nch2 = ch2 - ( 0 ) Label AF3',  'nch3 = ch3 - ( 0 ) Label F7',  'nch4 = ch4 - ( 0 ) Label F3',  'nch5 = ch5 - ( 0 ) Label FC1',  'nch6 = ch6 - ( 0 ) Label FC5',  'nch7 = ch7 - ( 0 ) Label T7',  'nch8 = ch8 - ( 0 ) Label C3',  'nch9 = ch9 - ( 0 ) Label CP1',  'nch10 = ch10 - ( 0 ) Label CP5',  'nch11 = ch11 - ( 0 ) Label P7',  'nch12 = ch12 - ( 0 ) Label P3',  'nch13 = ch13 - ( 0 ) Label Pz',  'nch14 = ch14 - ( 0 ) Label PO3',  'nch15 = ch15 - ( 0 ) Label O1',  'nch16 = ch16 - ( 0 ) Label Oz',  'nch17 = ch17 - ( 0 ) Label O2',  'nch18 = ch18 - ( 0 ) Label PO4',  'nch19 = ch19 - ( 0 ) Label P4',  'nch20 = ch20 - ( 0 ) Label P8',  'nch21 = ch21 - ( 0 ) Label CP6',  'nch22 = ch22 - ( 0 ) Label CP2',  'nch23 = ch23 - ( 0 ) Label C4',  'nch24 = ch24 - ( 0 ) Label T8',  'nch25 = ch25 - ( 0 ) Label FC6',  'nch26 = ch26 - ( 0 ) Label FC2',  'nch27 = ch27 - ( 0 ) Label F4',  'nch28 = ch28 - ( 0 ) Label F8',  'nch29 = ch29 - ( 0 ) Label AF4',  'nch30 = ch30 - ( 0 ) Label Fp2',  'nch31 = ch31 - ( 0 ) Label Fz',  'nch32 = ch32 - ( 0 ) Label Cz',  'nch33 = ch33 - ( 0 ) Label FCz',  'nch34 = ch34 - ( 0 ) Label Iz',  'nch35 = ch39 - ( 0 ) Label M1',  'nch36 = ch40 - ( 0 ) Label M2'} , 'ErrorMsg', 'popup', 'Warning', 'off' );    
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
    
    % Save original channels for all scalp electrodes
    originalEEG = EEG;
    originalEEG_chanLocs = EEG.chanlocs;
    clear EEG;
    %load sets cleaned with ICA components removed. ChOpResamp256PREP_ICAclean, _ChOpResamp256PREP_1HzHpRejChanData_RunICA
    EEG = pop_loadset('filename',['_ChOpResamp256PREP_1HzHpRejChanData_RunICA.set'],...
        'filepath',savePathRunICA);
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    
    % Count the external sensors
    exgChanRej = {}
    exgChanList = {'LO1', 'LO2', 'SO2', 'IO2'};
    for channel = 1:EEG.nbchan
        for exgChan = 1:length(exgChanList)
            if string(EEG.chanlocs(channel).labels) == exgChanList{exgChan}
                exgChanRej(end+1) = exgChanList(exgChan);
            end
        end
    end
    
    % Actually remove the external sensors
    for channel = 1:length(exgChanRej)
        EEG = pop_select( EEG, 'nochannel', exgChanRej(channel));
    end
    eeglab redraw;

    % Lookup channel locations again
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
    
%     % Detrend the data using PREP with default paramters to remove electrode drift and produce stationary data
%         % Same process as with PREP line noise: Applies 1.0 Hz highpass filter before detrending and returns UNFILTERED detrended data WITHOUT FILTER
%         % Note detrend is an alternative to DC offset removal: https://sccn.ucsd.edu/pipermail/eeglablist/2015/010729.html,https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5915520/, https://www.rdocumentation.org/packages/predtoolsTS/versions/0.1.1/topics/prep
%     EEG = removeTrend(EEG)
%     eeglab redraw;
%     
%     % remove average dc offset for further correction of line noise
%     EEG = pop_rmbase( EEG, [EEG.xmin      EEG.xmax]);
%     eeglab redraw;

    % filter
    EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2, 'RemoveDC', 'on' );
    
    % Remove even more bad chans, clean_rawdata default parameters
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off',...
        'BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    eeglab redraw;
    
    % Interpolate bad channels
    EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
    eeglab redraw;
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;

% 	% Rereference to MASTOIDS, remove mastoids
%      EEG = pop_reref( EEG, [35, 36]);
%      eeglab redraw;
%      EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
%      eeglab redraw;

    % Edit set name
    EEG = pop_editset(EEG, 'setname', ['_BandFiltRejChanInterpMastRef']);
    
    %save file
    EEG = pop_saveset( EEG, 'filename',['_BandFiltRejChanInterpMastRef.set'],...
         'filepath',savePath);

    clear EEG;
        EEG = pop_loadset('filename',['_BandFiltRejChanInterpMastRef.set'],...
        'filepath',loadPath);

    % create eventlist erplab
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
        [subName '_EventList_BandFiltRejChanInterpMastRef.txt'] );
   
     
    EEG  = pop_binlister( EEG , 'BDF', binListerPath,...
        'IndexEL',  1, 'SendEL2', 'Workspace&EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );

    
    EEG = pop_epochbin( EEG , [-200.0  1000.0],  'pre');
    %eeglab redraw;
%     	EEG = pop_gratton(EEG, 35, 'chans', 1:EEG.nbchan);		% Correct blinks using channel 35 = VEOG
% 	EEG = pop_gratton(EEG, 36, 'chans', 1:EEG.nbchan);	
    % Lookup channel locations one last time
    %EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    %eeglab redraw;
    
    % Edit set name
    EEG = pop_editset(EEG, 'setname', ['_BandFiltRejChanInterpMastRef_EListBinEpochBase']);
    
    %save file
    EEG = pop_saveset( EEG, 'filename',['_BandFiltRejChanInterpMastRef_EListBinEpochBase.set'],...
         'filepath',savePath);
% 
%     % file 8
% 
clear EEG;
EEG = pop_loadset('filename',['_BandFiltRejChanInterpMastRef_EListBinEpochBase.set'],...
'filepath',loadPath);
% EEG.event = eventTemplate;
%     EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist',...
%         ['_EventList_BandFiltRejChanInterpMastRef.txt'] );
%    
%     EEG.event = eventTemplate; 
%     EEG  = pop_binlister( EEG , 'BDF', binListerPath,...
%         'IndexEL',  1, 'SendEL2', 'Workspace&EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
% EEG.event = eventTemplate;
   % EEG = pop_epochbin( EEG , [-200.0  1000.0],  'pre');
    EEG  = pop_artmwppth( EEG , 'Channel',  1:EEG.nbchan, 'Flag', [ 1 2], 'Threshold',  100, 'Twindow', [ -199.2 996.1], 'Windowsize',  150, 'Windowstep',  75 );
    EEG  = pop_artflatline( EEG , 'Channel',  1:EEG.nbchan, 'Duration',  500, 'Flag', [ 1 3], 'Threshold', [ -0.5 0.5], 'Twindow', [ -199.2 996.1] );
    EEG  = pop_artdiff( EEG , 'Channel',  1:EEG.nbchan, 'Flag', [ 1 4], 'Threshold',  50, 'Twindow', [ -199.2 996.1] );
	

    % compuate average ERPs erplab 
    ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
      
    % save erpset
    ERP = pop_savemyerp(ERP,...
        'erpname', ['_FiltInterpMastRef'],...
        'filename', ['_FiltInterpMastRef.erp'],...
        'filepath', savePath);

    CURRENTERP = CURRENTERP + 1;
   % ALLERP(CURRENTERP) = ERP;
erns=ERP.bindata;

%x=mean(x,3);
EEG.data=erns;
[~,~,z]=size(EEG.data);
EEG.ntrials=ERP.ntrials;
EEG.trials=z;

x=EEG.data;
ern1=squeeze(x(:,:,1));
ern2=squeeze(x(:,:,2));
ern3=squeeze(x(:,:,3));
ern4=squeeze(x(:,:,4));
%save('lstSoarSingle5.mat','EEG');
