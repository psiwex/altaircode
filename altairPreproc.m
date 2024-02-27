function EEG = altairPreproc(EEG)
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

% load('C:\Users\John\Documents\MATLAB\soarData\OSU-00001-04B\Actiview\OSU-00001-04B-01-ERN.bdf.mat')

channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';

% EEG Processing Script for Gorka lab, James Glazer 3/7/23: glazerja1@gmail.com
%
% Processing Steps Simplified:
% 	1. Load raw BDf, save raw .set/.fdt datset.
% 	2. Resample, re-reference, filter.
% 	3. Remove/interpolate bad channels (save _removedchans and _interp .set/.fdt datasets).
% 	4. Create eventlist, binlister, segment/epoch w/baseline correction.
% 	5. Ocular Correct, artifact reject, calculate average ERPs.
% 	6. Save "completed" .set/.fdt dataset and .erp averaged erpset.
%
% How to use:
%   1. Place all raw BDF files in same folder and enter this path/location.
%   2. Put the name of each file in subName list.
%   3. Create empty folders where the data will go and enter their path/location in the script.
%       Recommended folder structure:
%           GorkaData\RawBDF\                           .bdf raw files for all subjects
%           GorkaData\Datasets\Raw:                     .set/.fdt datasets saved immediately after loading .bdf (raw data)
%           GorkaData\Datasets\Processing:              .set/.fdt datasets saved at intermediate processing steps (saved after important processing steps)
%           GorkaData\Datasets\Completed:               .set/.fdt datasets saved after completed preprocessing (ready for erp averaging)
%           GorkaData\EventLists\Raw:                   .txt raw eventlists saved containing all trial/event code information
%           GorkaData\EventLists\Processed:             .txt processed eventlists saved containing all artifact/bin information
%           GorkaData\Binlister\GorkaBinlister.txt:     .txt file containing binlister information for epoching/segmenting/averaging
%           GorkaData\Erpsets:                          .erp final fully processed erpset files ready for ERP plotting, data exporting, and grand averaging
%   4. Click "Run".
% 
% Processing Steps Summary:
%   Steps 1-4: Load raw BDF, edit/save .set/.fdt dataset, resample.
%   Steps 5-7: Remove unused/double channels, re-reference, create VEOG/HEOG channels and remove VEO+/VEO-/HEOR/HEOL
%   Steps 8-10: Filter and save .set/.fdt dataset with full channel information
%   Steps 11-14: Remove VEOG/HEOG, detect bad channels, reload dataset above with full channels, remove bad channels, save dataset, interpolate removed channels
%   Steps 15-19: Create eventlist/load binlist, epoch/segment (w/baseline correct), ocular correct, remove VEOG/HEOG
%   Steps 20-23: Artifact detect/reject, export eventlist with artifact information, get channel locations, save fully processed dataset
%   Steps 24-25: Compute average erps and save final .erp files ready for ERP plotting, data exporting, and grand averaging
% 
% Processing Steps Detailed:
% 1. Load the raw .BDF file
% 2. Edit dataset name and save raw .set/.fdt file
% 3. Resample data PROPERLY, For SIFT to ease antialiasing filter slope, see code from Makoto: 
% 4. Load channel locations from channelLocationFile
% 5. Channel Operations: Remove unused/double electrodes, reorder remaining channels: New Channel list: 0-34 = scalp, 35-38 = EOGs, 39-40 = Mastoids
    % 5a. Remove following electrodes: ST1/ST2/EKG1/EKG2/PA1/PA2 (channels 33-38) and GSR1/GSR2/ERG1/ERG2/RESP/PLET/TEMP (channels 55-61)
    % 5b. Remove double electrodes: VEO+/VEO-/HEOR/HEOL/M1/M2/FCz/Iz (channels 47-54)
    % 5c. Move FCz/Iz to channels 33-34, Move external sensors (M1/M2/VEO+/VEO-/HEOR/HEOL) to end of channel list 35-40
% 6. Re-reference to average of mastoids (channels 39/40), remove M1/M2
% 7. Create VEOG & HEOG difference for Gratton & Coles Ocular Correction Regression performed later, remove VEO+/VEO-/HEOR/HEOL
% 8. Filter the Data: IIR Butterworth bandpass 0.1 to 30 Hz
% 9. Reload channel locations
% 10. Edit dataset name and save preprocessed .set/.fdt file with FULL channel information BEFORE removing channels
% 11. Automatic bad channel detection/rejection using clean_rawdata
%   11a. First remove VEOG/HEOG BEFORE bad channel detection/removal: Final Channel list: 0-34 = SCALP chans
%   11b. Reload channel locations
%   11c. Automatically detect and remove bad SCALP chans using clean_rawdata default parameters
%   11d. Get list of full remaining "good" SCALP EEG channels
%   11e. Add VEOG/HEOG to trimChans list because these are "good" by default as we don't want to remove them
% 12. Remove bad channels, keep VEOG/HEOG for ocular correction later
%   12a: Reload dataset recently saved BEFORE removing bad channels that still has VEOG/HEOG
%   12b. Save original channels for all scalp electrodes, used to interpolate bad electrodes later
%   12c. get list of channels before channel rejection
% 	12d. get list of bad/rejected channels by finding the difference between allChans and trimChans lists
%   12f. Actually remove the bad channels using badChansList
% 13. Edit dataset name and save preprocessed .set/.fdt file AFTER removing channels
% 14. Interpolate bad channels
% 15. Create & Save EventLists
% 16. Separate the trials into Bins by loading your BinLister file
% 17. Epoch the Data: Window and Baseline
% 18. Blink correction using Gratton & Coles ocular correction
% 19. Remove VEOG/HEOG after Ocular Correction: Final Channel list: 0-34 = scalp, Reload channel locations
% 20. Automatically detect & reject trials/epochs for each event code in each bin
%   20a. Artifact Rejection: ERPLAB Moving Window: Remove epochs exceeding voltage threshold as a moving window with a total amplitude, window size, and window step
%   20b. Artifact Rejection: ERPLAB Sample-to-Sample: Remove epochs exceeding voltage threshold between two sampling points
%   20c. Artifact Rejection: ERPLAB Flatline: Remove epochs with flatlined data lower than voltage threshold
% 21. Export EventList containing bin/artifact information
% 22. Look up channel locations again
% 23. Edit dataset name and save fully processed .set/.fdt file that is ready for averaging into erpset .erp file
% 24. Compuate average ERPs using erplab to create .erp file
% 25. Save the erpset .erp file


% ===== Manually enter the path location on your machine for the following folders =====
%clear all; 
close all; clc;
% path containing raw .BDF files to load
raw_bdf_loadpath = 'C:\Users\John\Documents\MATLAB\soarData\';

% path to save raw datasets as .set/.fdt eeglab format
raw_dataset_savepath = 'C:\Users\glaze\Desktop\GorkaScripts\data\datasets\Raw\';
% path to save .set/.fdt datasets at intermediate processing steps: optional but strongly recommended
%   example 1: datasets saved after bad channel rejection can be used to determine which channels were removed and interpolated
%   example 2: datasets saved after artifact rejection can be used to determine which and how many epochs/trials/conditions were rejected 
%       Note: This is required to use SummaryScript.m to save details on bad channels/artifact rejection results
ongoing_dataset_savepath = 'C:\Users\glaze\Desktop\GorkaScripts\data\datasets\Processing\';
% path to save fully processed .set/.fdt files before ERP averaging
processed_dataset_savepath = 'C:\Users\glaze\Desktop\GorkaScripts\data\datasets\Completed\';
% path to save erpsets in erplab .erp format
erpset_savepath = 'C:\Users\glaze\Desktop\GorkaScripts\data\Erpsets\';
erpset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\erpLabs\';
% save raw and processed eventlist path: 
raw_eventlist_savepath = 'C:\Users\glaze\Desktop\GorkaScripts\data\EventLists\Raw\';
processed_eventlist_savepath = 'C:\Users\glaze\Desktop\GorkaScripts\data\EventLists\Processed\';
% binlister path: see https://github.com/lucklab/erplab/blob/master/pop_functions/pop_binlister.m
binlister_loadpath = 'C:\Users\John\Documents\MATLAB\soarEtl\GorkaBinlister.txt';
% channelLocationFile: this path is found in your eeglab dipfit plugin folder: eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
%channelLocationFile = 'C:\Users\glaze\Documents\MatLabPrograms\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';

	% 2. Edit dataset name and save raw .set/.fdt file
	%EEG = pop_editset(EEG, 'setname', [subName{iSubject} '_Raw']);
      % https://eeglab.org/others/Firfilt_FAQ.html#Q._For_Granger_Causality_analysis.2C_what_filter_should_be_used.3F_.2804.2F26.2F2018_Updated.29
    EEG = pop_resample(EEG, 256, 0.8, 0.4); % BioSemi

    % 4. Load channel locations from channelLocationFile
    EEG = pop_chanedit(EEG, 'lookup', channelLocationFile);
close; 
    x=EEG.data;

    avDum=.5*(x(39,:)+x(40,:));
    x=x-avDum;

    x35=(x(35,:)-x(36,:));
    x36=(x(37,:)-x(38,:));
    x(35,:)=x35;
    x(36,:)=x36;
    EEG.data=x;


	% 8. Filter the Data: IIR Butterworth bandpass 0.1 to 30 Hz
	EEG = pop_basicfilter(EEG, 1:EEG.nbchan,...
		'Boundary', 'boundary',...	% Boundary events
		'Cutoff', [ 0.1 30],...		% High and low cutoff
		'Design', 'butter',...		% IIR Butterworth filter
		'Filter', 'bandpass',...	% Bandpass filter type
		'Order',  2,...				% Filter order
		'RemoveDC', 'on' );			% Remove DC offset

    % 9. Reload channel locations
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile); close;
    eeglab redraw; close all;

    % 10. Edit dataset name and save preprocessed .set/.fdt file with FULL channel information BEFORE removing channels
	%EEG = pop_editset(EEG, 'setname', [subName{iSubject} '_ChopResampFilt']);
	%EEG = pop_saveset(EEG, 'filename',[subName{iSubject} '_ChopResampFilt.set'], 'filepath', ongoing_dataset_savepath);

    % ===== Steps 11-14: remove VEOG/HEOG, detect bad channels, reload dataset above with full channels, remove bad channels, save dataset, interpolate removed channels =====
    
    % 11. Automatic bad channel detection/rejection using clean_rawdata
    %   11a. First remove VEOG/HEOG BEFORE bad channel detection/removal: Final Channel list: 0-34 = SCALP chans
    EEG = pop_select(EEG, 'nochannel',{'VEOG','HEOG'}); 
    %   11b. Reload channel locations
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile); close;
    eeglab redraw; close all;
    %   11c. Automatically detect and remove bad SCALP chans using clean_rawdata default parameters
    EEG = pop_clean_rawdata(EEG,...
        'FlatlineCriterion', 5,...      % Maximum tolerated flatline duration in seconds (Default: 5)
        'ChannelCriterion', 0.85,...    % Minimum channel correlation with neighboring channels (default: 0.85)
        'LineNoiseCriterion', 4,...     % Maximum line noise relative to signal in standard deviations (default: 4)
        'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    %eeglab redraw;
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
%    EEG = pop_loadset('filename',[subName{iSubject} '_ChopResampFilt.set'], 'filepath', ongoing_dataset_savepath);
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
    eeglab redraw; close all;
    %   12f. Actually remove the bad channels using badChansList
    for channel = 1:length(badChansList)
        EEG = pop_select(EEG, 'nochannel',{badChansList{channel}});
    end
    eeglab redraw; close all;

    % 13. Edit dataset name and save preprocessed .set/.fdt file AFTER removing channels
	%EEG = pop_editset(EEG, 'setname', [subName{iSubject} '_ChopResampFilt_removedchans']);
	%EEG = pop_saveset(EEG, 'filename',[subName{iSubject} '_ChopResampFilt_removedchans.set'], 'filepath', ongoing_dataset_savepath);

    % 14. Interpolate bad channels, resave dataset
    EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
    %eeglab redraw;
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile); close;
    eeglab redraw; close all;
	%EEG = pop_editset(EEG, 'setname', [subName{iSubject} '_ChopResampFilt_Interp']);
	%EEG = pop_saveset(EEG, 'filename',[subName{iSubject} '_ChopResampFilt_Interp.set'], 'filepath', ongoing_dataset_savepath);
    %eeglab redraw;

    % ===== Steps 15-19: create eventlist/load binlist, epoch/segment (w/baseline correct), ocular correct, remove VEOG/HEOG =====
	
    % 15. Create & Save EventLists
	% 	See: https://jennifervendemia.files.wordpress.com/2013/03/very-simple-notes-on-event-lists-file-formats-in-erplab.pdf
    EEG  = pop_creabasiceventlist(EEG,...
        'AlphanumericCleaning', 'on',...        % Replace Letters with Numbers
        'BoundaryNumeric', { -99 },...          % Boundary event marker
        'BoundaryString', { 'boundary' },...    % Boundary string marker
        'Eventlist', ['Raw_EventList_ern.txt']);

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
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile); close;
    eeglab redraw; close all;

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
%     EEG = pop_exporteegeventlist(EEG,...
%         'Filename', ['Processed_EventList_ern.txt']);

	% 22. Look up channel locations again
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile); close;
    eeglab redraw; close all;
	

ERP = pop_averager(EEG, 'Criterion', 'all');

x=ERP.bindata;
x=mean(x,3);
EEG.data=x;



end
