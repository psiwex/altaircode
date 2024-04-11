function [EEG,ERP,erns] = altairPreproc(fName,raw_bdf_loadpath,raw_dataset_savepath,ongoing_dataset_savepath,processed_dataset_savepath,erpset_savepath,raw_eventlist_savepath,processed_eventlist_savepath,binlister_loadpath,channelLocationFile)
% Extract the EEG, based on Gorka's code
%
%  Parameters:
%     filename  EEGLAB EEG structure

%   Output:
%     EEG     EEGLAB EEG structure with the output
%
%   Written by:  John LaRocco, Feb 2016
%
% Assumes:  SOAR preprocessing base on Gorka for rough EEG. 

subName = {'TRY100a_ERN', 'TRY101a_ERN','TRY102a_ERN'};

% load EEGlab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% load ERPlab
ALLERP = buildERPstruct([]);
CURRENTERP = 0;

% Process data
%for iSubject = 1:length(subName)

    % ===== Steps 1-4: Load raw BDF, edit/save .set/.fdt dataset, resample =====
    
	% 1. Load the raw .BDF file
    EEG = pop_biosig(fName);
    %EEG = pop_biosig([raw_bdf_loadpath subName{iSubject} '.bdf']);

	% 2. Edit dataset name and save raw .set/.fdt file
	EEG = pop_editset(EEG, 'setname', [fName '_Raw']);
	EEG = pop_saveset(EEG, 'filename',[fName '_Raw.set'], 'filepath', raw_dataset_savepath);

    % 3. Resample data PROPERLY, For SIFT to ease antialiasing filter slope, see code from Makoto: 
        % https://sccn.ucsd.edu/wiki/Makoto%27s_useful_EEGLAB_code
        % https://eeglab.org/others/Firfilt_FAQ.html#Q._For_Granger_Causality_analysis.2C_what_filter_should_be_used.3F_.2804.2F26.2F2018_Updated.29
    EEG = pop_resample(EEG, 256, 0.8, 0.4); % BioSemi

    % 4. Load channel locations from channelLocationFile
    EEG = pop_chanedit(EEG, 'lookup', channelLocationFile);
    eeglab redraw;

    % ===== Steps 5-7: Remove unused/double channels, re-reference, create VEOG/HEOG channels and remove VEO+/VEO-/HEOR/HEOL =====
    
    % 5. Channel Operations: Remove unused/double electrodes, reorder remaining channels: New Channel list: 0-34 = scalp, 35-38 = EOGs, 39-40 = Mastoids
    %   5a. Remove following electrodes: ST1/ST2/EKG1/EKG2/PA1/PA2 (channels 33-38) and GSR1/GSR2/ERG1/ERG2/RESP/PLET/TEMP (channels 55-61)
    %   5b. Remove double electrodes: VEO+/VEO-/HEOR/HEOL/M1/M2/FCz/Iz (channels 47-54)
    %   5c. Move FCz/Iz to channels 33-34, Move external sensors (M1/M2/VEO+/VEO-/HEOR/HEOL) to end of channel list 35-40
    % 
    % WARNING: if data channels differ from TRY100a_ERN/TRY101a_ERN/TRY102a_ERN you will need to edit this section to match
    %   Note: to recreate this code using different channels, use erplab -> EEG channel operations 
    %   -> click "Clear Equations" -> check "Create new dataset" -> click reference assistant
    %   -> enter 0 into "Ch_REF = ", check "Copy original label to new label"
    %   -> check "If a channel is not being re-referenced, include an equation for simply copying the channel (recommended for independent transformations)"
    %   -> check "All Channels" -> click "ok", channel equations will appear in the white box
    %   Now you can edit the equations so that they match the locations below, then -> click "Run"
    % After it runs, type "EEG.history" into the command line to get your code (note: you can delete the " - ( 0 )")
    EEG = pop_eegchanoperator(EEG, {...
        'nch1 = ch1 Label Fp1',    'nch2 = ch2 Label AF3',     'nch3 = ch3 Label F7',     'nch4 = ch4 Label F3',    'nch5 = ch5 Label FC1',...
        'nch6 = ch6 Label FC5',    'nch7 = ch7 Label T7',      'nch8 = ch8 Label C3',     'nch9 = ch9 Label CP1',   'nch10 = ch10 Label CP5',...
        'nch11 = ch11 Label P7',   'nch12 = ch12 Label P3',    'nch13 = ch13 Label Pz',   'nch14 = ch14 Label PO3', 'nch15 = ch15 Label O1',...
        'nch16 = ch16 Label Oz',   'nch17 = ch17 Label O2',    'nch18 = ch18 Label PO4',  'nch19 = ch19 Label P4',  'nch20 = ch20 Label P8',...
        'nch21 = ch21 Label CP6',  'nch22 = ch22 Label CP2',   'nch23 = ch23 Label C4',   'nch24 = ch24 Label T8',  'nch25 = ch25 Label FC6',...
        'nch26 = ch26 Label FC2',  'nch27 = ch27 Label F4',    'nch28 = ch28 Label F8',   'nch29 = ch29 Label AF4', 'nch30 = ch30 Label Fp2',...
        'nch31 = ch31 Label Fz',   'nch32 = ch32 Label Cz',    'nch33 = ch45 Label FCz',  'nch34 = ch46 Label Iz',  'nch35 = ch39 Label VEO+',...
        'nch36 = ch40 Label VEO-', 'nch37 = ch41 Label HEOR',  'nch38 = ch42 Label HEOL', 'nch39 = ch43 Label M1',  'nch40 = ch44 Label M2'},...
         'Warning', 'off' );

    % 6. Re-reference to average of mastoids (channels 39/40), remove M1/M2
    % 	Note: to recreate this code using different channels, follow the steps above for Channel Operations but enter ((ch39 + ch40)/2) into "Ch_REF = "
    %   -> then remove the last two lines ('nch39 = nch39 - ((ch39 + ch40)/2) Label M1',  'nch40 = ch40 - ((ch39 + ch40)/2) Label M2')
    %   -> then click "Run" and afterwards type "EEG.history" into the command line to get your code
    EEG = pop_eegchanoperator(EEG, {...
        'nch1 = ch1 - ((ch39 + ch40)/2) Label Fp1',    'nch2 = ch2 - ((ch39 + ch40)/2) Label AF3',     'nch3 = ch3 - ((ch39 + ch40)/2) Label F7',...
        'nch4 = ch4 - ((ch39 + ch40)/2) Label F3',     'nch5 = ch5 - ((ch39 + ch40)/2) Label FC1',     'nch6 = ch6 - ((ch39 + ch40)/2) Label FC5',...
        'nch7 = ch7 - ((ch39 + ch40)/2) Label T7',     'nch8 = ch8 - ((ch39 + ch40)/2) Label C3',      'nch9 = ch9 - ((ch39 + ch40)/2) Label CP1',...
        'nch10 = ch10 - ((ch39 + ch40)/2) Label CP5',  'nch11 = ch11 - ((ch39 + ch40)/2) Label P7',    'nch12 = ch12 - ((ch39 + ch40)/2) Label P3',...
        'nch13 = ch13 - ((ch39 + ch40)/2) Label Pz',   'nch14 = ch14 - ((ch39 + ch40)/2) Label PO3',   'nch15 = ch15 - ((ch39 + ch40)/2) Label O1',...
        'nch16 = ch16 - ((ch39 + ch40)/2) Label Oz',   'nch17 = ch17 - ((ch39 + ch40)/2) Label O2',    'nch18 = ch18 - ((ch39 + ch40)/2) Label PO4',...
        'nch19 = ch19 - ((ch39 + ch40)/2) Label P4',   'nch20 = ch20 - ((ch39 + ch40)/2) Label P8',    'nch21 = ch21 - ((ch39 + ch40)/2) Label CP6',...
        'nch22 = ch22 - ((ch39 + ch40)/2) Label CP2',  'nch23 = ch23 - ((ch39 + ch40)/2) Label C4',    'nch24 = ch24 - ((ch39 + ch40)/2) Label T8',...
        'nch25 = ch25 - ((ch39 + ch40)/2) Label FC6',  'nch26 = ch26 - ((ch39 + ch40)/2) Label FC2',   'nch27 = ch27 - ((ch39 + ch40)/2) Label F4',...
        'nch28 = ch28 - ((ch39 + ch40)/2) Label F8',   'nch29 = ch29 - ((ch39 + ch40)/2) Label AF4',   'nch30 = ch30 - ((ch39 + ch40)/2) Label Fp2',...
        'nch31 = ch31 - ((ch39 + ch40)/2) Label Fz',   'nch32 = ch32 - ((ch39 + ch40)/2) Label Cz',    'nch33 = ch33 - ((ch39 + ch40)/2) Label FCz',...
        'nch34 = ch34 - ((ch39 + ch40)/2) Label Iz',   'nch35 = ch35 - ((ch39 + ch40)/2) Label VEO+',  'nch36 = ch36 - ((ch39 + ch40)/2) Label VEO-',...
        'nch37 = ch37 - ((ch39 + ch40)/2) Label HEOR', 'nch38 = ch38 - ((ch39 + ch40)/2) Label HEOL'}, 'ErrorMsg', 'popup', 'Warning', 'off' );

    % 7. Create VEOG & HEOG difference for Gratton & Coles Ocular Correction Regression performed later, remove VEO+/VEO-/HEOR/HEOL
    %   To recreate using different channels, follow identical steps above for Channel Operations, Once the equations are created in the white box:
    %   Delete the last four lines (nch35 = ch35 Label VEO+, nch36 = ch36, Label VEO-, nch37 = ch37 Label HEOR, nch38 = ch38 Label HEOL)
    %   Add the following two lines:
    %       nch35 = ch35-ch36 Label VEOG
    %       nch36 = ch37-ch38 Label HEOG
    %   Click "Run", type EEG.history afterwards to get code
    EEG = pop_eegchanoperator(EEG, {...
        'nch1 = ch1 Label Fp1',  'nch2 = ch2 Label AF3',  'nch3 = ch3 Label F7',  'nch4 = ch4 Label F3',...
        'nch5 = ch5 Label FC1',  'nch6 = ch6 Label FC5',  'nch7 = ch7 Label T7',  'nch8 = ch8 Label C3',...
        'nch9 = ch9 Label CP1',  'nch10 = ch10 Label CP5',  'nch11 = ch11 Label P7',  'nch12 = ch12 Label P3',...
        'nch13 = ch13 Label Pz',  'nch14 = ch14 Label PO3',  'nch15 = ch15 Label O1',  'nch16 = ch16 Label Oz',...
        'nch17 = ch17 Label O2',  'nch18 = ch18 Label PO4',  'nch19 = ch19 Label P4',  'nch20 = ch20 Label P8',...
        'nch21 = ch21 Label CP6',  'nch22 = ch22 Label CP2',  'nch23 = ch23 Label C4',  'nch24 = ch24 Label T8',...
        'nch25 = ch25 Label FC6',  'nch26 = ch26 Label FC2',  'nch27 = ch27 Label F4',  'nch28 = ch28 Label F8',...
        'nch29 = ch29 Label AF4',  'nch30 = ch30 Label Fp2',  'nch31 = ch31 Label Fz',  'nch32 = ch32 Label Cz',...
        'nch33 = ch33 Label FCz',  'nch34 = ch34 Label Iz',  'nch35 = ch35-ch36 Label VEOG',  'nch36 = ch37-ch38 Label HEOG'},...
        'ErrorMsg', 'popup', 'Warning', 'off' );
    
    % ===== Steps 8-10: Filter and save .set/.fdt dataset with full channel information =====
    
	% 8. Filter the Data: IIR Butterworth bandpass 0.1 to 30 Hz
	EEG = pop_basicfilter(EEG, 1:EEG.nbchan,...
		'Boundary', 'boundary',...	% Boundary events
		'Cutoff', [ 0.1 30],...		% High and low cutoff
		'Design', 'butter',...		% IIR Butterworth filter
		'Filter', 'bandpass',...	% Bandpass filter type
		'Order',  2,...				% Filter order
		'RemoveDC', 'on' );			% Remove DC offset

    % 9. Reload channel locations
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;

    % 10. Edit dataset name and save preprocessed .set/.fdt file with FULL channel information BEFORE removing channels
	EEG = pop_editset(EEG, 'setname', [fName '_ChopResampFilt']);
	EEG = pop_saveset(EEG, 'filename',[fName '_ChopResampFilt.set'], 'filepath', ongoing_dataset_savepath);

    % ===== Steps 11-14: remove VEOG/HEOG, detect bad channels, reload dataset above with full channels, remove bad channels, save dataset, interpolate removed channels =====
    
    % 11. Automatic bad channel detection/rejection using clean_rawdata
    %   11a. First remove VEOG/HEOG BEFORE bad channel detection/removal: Final Channel list: 0-34 = SCALP chans
    EEG = pop_select(EEG, 'nochannel',{'VEOG','HEOG'}); 
    %   11b. Reload channel locations
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
    %   11c. Automatically detect and remove bad SCALP chans using clean_rawdata default parameters
    EEG = pop_clean_rawdata(EEG,...
        'FlatlineCriterion', 5,...      % Maximum tolerated flatline duration in seconds (Default: 5)
        'ChannelCriterion', 0.85,...    % Minimum channel correlation with neighboring channels (default: 0.85)
        'LineNoiseCriterion', 4,...     % Maximum line noise relative to signal in standard deviations (default: 4)
        'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    eeglab redraw;
    %   11d. Get list of full remaining "good" SCALP EEG channels
    trimChans = {};
    for channel = 1:EEG.nbchan
        trimChans{end+1} = EEG.chanlocs(channel).labels;
    end
    %   11e. Add VEOG/HEOG to trimChans list because these are "good" by default as we don't want to remove them
    trimChans{end+1} = 'VEOG';
    trimChans{end+1} = 'HEOG';

    % 12. Remove bad channels, keep VEOG/HEOG for ocular correction later
    %   12a: Reload dataset recently saved BEFORE removing bad channels that still has VEOG/HEOG
    EEG = pop_loadset('filename',[fName '_ChopResampFilt.set'], 'filepath', ongoing_dataset_savepath);
    %   12b. Save original channels for all scalp electrodes, used to interpolate bad electrodes later
    originalEEG = EEG;
    %   12c. get list of channels before channel rejection
    allChans = {};
    for channel = 1:EEG.nbchan
        allChans{end+1} = EEG.chanlocs(channel).labels;
    end
    % 	12d. get list of bad/rejected channels by finding the difference between allChans and trimChans lists
    badChansList = {};
    for channel = 1:length(allChans)
        badChan = strcmp(trimChans, allChans(channel));
        if sum(badChan) == 0
            badChansList{end+1} = allChans{channel};
        end
    end
    eeglab redraw;
    %   12f. Actually remove the bad channels using badChansList
    for channel = 1:length(badChansList)
        EEG = pop_select(EEG, 'nochannel',{badChansList{channel}});
    end
    eeglab redraw;

    % 13. Edit dataset name and save preprocessed .set/.fdt file AFTER removing channels
	EEG = pop_editset(EEG, 'setname', [fName '_ChopResampFilt_removedchans']);
	EEG = pop_saveset(EEG, 'filename',[fName '_ChopResampFilt_removedchans.set'], 'filepath', ongoing_dataset_savepath);

    % 14. Interpolate bad channels, resave dataset
    EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
    eeglab redraw;
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
	EEG = pop_editset(EEG, 'setname', [fName '_ChopResampFilt_Interp']);
	EEG = pop_saveset(EEG, 'filename',[fName '_ChopResampFilt_Interp.set'], 'filepath', ongoing_dataset_savepath);
    eeglab redraw;

    % ===== Steps 15-19: create eventlist/load binlist, epoch/segment (w/baseline correct), ocular correct, remove VEOG/HEOG =====
	
    % 15. Create & Save EventLists
	% 	See: https://jennifervendemia.files.wordpress.com/2013/03/very-simple-notes-on-event-lists-file-formats-in-erplab.pdf
%     EEG  = pop_creabasiceventlist(EEG,...
%         'AlphanumericCleaning', 'on',...        % Replace Letters with Numbers
%         'BoundaryNumeric', { -99 },...          % Boundary event marker
%         'BoundaryString', { 'boundary' },...    % Boundary string marker
%         'Eventlist', [raw_eventlist_savepath 'Raw_EventList_' fName '.txt']);
    EEG  = pop_creabasiceventlist(EEG,...
        'AlphanumericCleaning', 'on',...        % Replace Letters with Numbers
        'BoundaryNumeric', { -99 },...          % Boundary event marker
        'BoundaryString', { 'boundary' },...    % Boundary string marker
        'Eventlist', 'raw');

	% 16. Separate the trials into Bins by loading your BinLister file
	% 	See: https://socialsci.libretexts.org/Bookshelves/Psychology/Book%3A_Applied_Event-Related_Potential_Data_Analysis_(Luck)/02%3A_Processing_the_Data_from_One_Participant_in_the_ERP_CORE_N400_Experiment/2.06%3A_Exercise-_Assigning_Events_to_Bins_with_BINLISTER
	EEG = pop_binlister(EEG ,...
		'BDF', binlister_loadpath,...
		'IndexEL',  1,...                       % Event List Index
		'SendEL2', 'Workspace&EEG',...          % Send the new Bins to the workplace and the EEG file
		'UpdateEEG', 'on',...                   % Update the EEG file
		'Voutput', 'EEG' );

	% 17. Epoch the Data: Window and Baseline
	EEG = pop_epochbin(EEG,...
		[-500.0  1000.0],...                    % Window for Epoch
		'-500 -300');                           % Baseline window
    
	% 18. Blink correction using Gratton & Coles ocular correction
    %   Regression-based method to remove blink and horizontal eye movements using the difference between VEO and HEO EOG electordes
    % === WARNING 1: VEOG and HEOG must be channels 35 and 36, respectively. If they are not, refer to above to recreate them and enter their channel number below
    %       Note: this plugin is currently unavailable: contact glazerja1@gmail.com or Matthias Ihrke <mihrke@uni-goettingen.de> (Copyright (C) 2007)
	EEG = pop_gratton(EEG, 35, 'chans', 1:EEG.nbchan);		% Correct blinks using channel 35 = VEOG
	EEG = pop_gratton(EEG, 36, 'chans', 1:EEG.nbchan);		% Correct horizontal eye movements using channel 36 = HEOG
    % === WARNING 2: Sometimes pop_gratton will give an error because the data length does not divide evenly into the ocular correction time windows.
    %   Use below alternative code if above gives error (will not significantly change results):
	% EEG = pop_gratton(EEG, 35, 'chans', 1:EEG.nbchan - 1, 'blinkcritwin', '22', 'blinkcritvolt', '200');
	% EEG = pop_gratton(EEG, 36, 'chans', 1:EEG.nbchan, 'blinkcritwin', '22', 'blinkcritvolt', '200');
    % If still gives error, play with 'blinkcritwin' and 'blinkcritvolt' values from 17-23 and 190-210 respectively, for example: 
	% EEG = pop_gratton(EEG, 35, 'chans', 1:EEG.nbchan - 1, 'blinkcritwin', '21', 'blinkcritvolt', '198');
    
    % 19. Remove VEOG/HEOG after Ocular Correction: Final Channel list: 0-34 = scalp, Reload channel locations
    EEG = pop_select(EEG, 'nochannel',{'VEOG','HEOG'}); 
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;

    % ===== Steps 20-23: artifact detect/reject, export eventlist with artifact information, get channel locations, save fully processed dataset =====
    
    % 20. Automatically detect & reject trials/epochs for each event code in each bin
    %   20a. Artifact Rejection: ERPLAB Moving Window: Remove epochs exceeding voltage threshold as a moving window with a total amplitude, window size, and window step
	EEG = pop_artmwppth(EEG ,...
		'Channel',      1:EEG.nbchan,...	% Set of channels to be tested
		'Flag',         [ 1 2],...			% Flag rejected trials onto the Event List
		'Threshold',    75,...              % Amplitude threshold for rejection
		'Twindow',      [ -500 1000],...	% Test window
		'Windowsize',   200,...             % Moving window size
		'Windowstep',   100 );              % Moving window step

    %   20b. Artifact Rejection: ERPLAB Sample-to-Sample: Remove epochs exceeding voltage threshold between two sampling points
	EEG = pop_artdiff(EEG ,...
		'Channel',      1:EEG.nbchan,...	% Set of channels to be tested
		'Flag',         [ 1 3],...			% Flag rejected trials onto the Event List
		'Threshold',    50,...              % Threshold for rejection
		'Twindow',      [ -500 1000] ); 	% Test window

    %   20c. Artifact Rejection: ERPLAB Flatline: Remove epochs with flatlined data lower than voltage threshold
	EEG = pop_artflatline(EEG ,...
		'Channel',      1:EEG.nbchan,...	% Set of channels to be tested
		'Duration',     498,...             % Duration of test window
		'Flag',         [ 1 4],...			% Flag rejected trials onto the Event List
		'Threshold',    [ -0.5 0.5],...     % Threshold for low amplitude rejection
		'Twindow',      [ -500 1000] );     % Test window

	% 21. Export EventList containing bin/artifact information
    EEG = pop_exporteegeventlist(EEG,...
        'Filename', [processed_eventlist_savepath 'Processed_EventList_' fName '.txt']);

	% 22. Look up channel locations again
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    eeglab redraw;
	
    % 23. Edit dataset name and save fully processed .set/.fdt file that is ready for averaging into erpset .erp file
	EEG = pop_editset(EEG, 'setname', [fName '_ChOpResamp_FiltElist_BinEpochOC_ChanRejInterp']);
	EEG = pop_saveset(EEG, 'filename',[fName '_ChOpResamp_FiltElist_BinEpochOC_ChanRejInterp.set']);
    eeglab redraw;
    
    % ===== Steps 24-25: Compute average erps and save final .erp files ready for ERP plotting, data exporting, and grand averaging =====

    % 24. Compuate average ERPs using erplab to create .erp file
    ERP = pop_averager(EEG, 'Criterion', 'good', 'ExcludeBoundary', 'on');

	% 25. Save the erpset .erp file
	ERP = pop_savemyerp(ERP,...
		'erpname',  [fName '_erpset'],...		% Name the ERP set
		'filename', [fName '_erpset.erp'],...	% Name the file
		'filepath', erpset_savepath,...                     % Path to save ERP set
		'Warning', 'off');

	% update erplab
	CURRENTERP = CURRENTERP + 1;
	ALLERP(CURRENTERP) = ERP;
erns=ERP.bindata;

%x=mean(x,3);
EEG.data=erns;
[~,~,z]=size(EEG.data);
EEG.ntrials=ERP.ntrials;
EEG.trials=z;

end
