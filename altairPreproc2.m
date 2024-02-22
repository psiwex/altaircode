function EEG = altairPreproc(EEG)
% Extract the EEG
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

ALLERP = buildERPstruct([]);

CURRENTERP = 0;

EEG = pop_resample(EEG, 256, 0.8, 0.4); % BioSemi

    % 4. Load channel locations from channelLocationFile
EEG = pop_chanedit(EEG, 'lookup', channelLocationFile);
%eeglab redraw;

% EEG = pop_eegchanoperator(EEG, {...
%         'nch1 = ch1 Label Fp1',    'nch2 = ch2 Label AF3',     'nch3 = ch3 Label F7',     'nch4 = ch4 Label F3',    'nch5 = ch5 Label FC1',...
%         'nch6 = ch6 Label FC5',    'nch7 = ch7 Label T7',      'nch8 = ch8 Label C3',     'nch9 = ch9 Label CP1',   'nch10 = ch10 Label CP5',...
%         'nch11 = ch11 Label P7',   'nch12 = ch12 Label P3',    'nch13 = ch13 Label Pz',   'nch14 = ch14 Label PO3', 'nch15 = ch15 Label O1',...
%         'nch16 = ch16 Label Oz',   'nch17 = ch17 Label O2',    'nch18 = ch18 Label PO4',  'nch19 = ch19 Label P4',  'nch20 = ch20 Label P8',...
%         'nch21 = ch21 Label CP6',  'nch22 = ch22 Label CP2',   'nch23 = ch23 Label C4',   'nch24 = ch24 Label T8',  'nch25 = ch25 Label FC6',...
%         'nch26 = ch26 Label FC2',  'nch27 = ch27 Label F4',    'nch28 = ch28 Label F8',   'nch29 = ch29 Label AF4', 'nch30 = ch30 Label Fp2',...
%         'nch31 = ch31 Label Fz',   'nch32 = ch32 Label Cz',    'nch33 = ch45 Label FCz',  'nch34 = ch46 Label Iz',  'nch35 = ch39 Label VEO+',...
%         'nch36 = ch40 Label VEO-', 'nch37 = ch41 Label HEOR',  'nch38 = ch42 Label HEOL', 'nch39 = ch43 Label M1',  'nch40 = ch44 Label M2'},...
%         'ErrorMsg', 'popup', 'Warning', 'off' );
% 
% EEG = pop_eegchanoperator(EEG, {...
%         'nch1 = ch1 - ((ch39 + ch40)/2) Label Fp1',    'nch2 = ch2 - ((ch39 + ch40)/2) Label AF3',     'nch3 = ch3 - ((ch39 + ch40)/2) Label F7',...
%         'nch4 = ch4 - ((ch39 + ch40)/2) Label F3',     'nch5 = ch5 - ((ch39 + ch40)/2) Label FC1',     'nch6 = ch6 - ((ch39 + ch40)/2) Label FC5',...
%         'nch7 = ch7 - ((ch39 + ch40)/2) Label T7',     'nch8 = ch8 - ((ch39 + ch40)/2) Label C3',      'nch9 = ch9 - ((ch39 + ch40)/2) Label CP1',...
%         'nch10 = ch10 - ((ch39 + ch40)/2) Label CP5',  'nch11 = ch11 - ((ch39 + ch40)/2) Label P7',    'nch12 = ch12 - ((ch39 + ch40)/2) Label P3',...
%         'nch13 = ch13 - ((ch39 + ch40)/2) Label Pz',   'nch14 = ch14 - ((ch39 + ch40)/2) Label PO3',   'nch15 = ch15 - ((ch39 + ch40)/2) Label O1',...
%         'nch16 = ch16 - ((ch39 + ch40)/2) Label Oz',   'nch17 = ch17 - ((ch39 + ch40)/2) Label O2',    'nch18 = ch18 - ((ch39 + ch40)/2) Label PO4',...
%         'nch19 = ch19 - ((ch39 + ch40)/2) Label P4',   'nch20 = ch20 - ((ch39 + ch40)/2) Label P8',    'nch21 = ch21 - ((ch39 + ch40)/2) Label CP6',...
%         'nch22 = ch22 - ((ch39 + ch40)/2) Label CP2',  'nch23 = ch23 - ((ch39 + ch40)/2) Label C4',    'nch24 = ch24 - ((ch39 + ch40)/2) Label T8',...
%         'nch25 = ch25 - ((ch39 + ch40)/2) Label FC6',  'nch26 = ch26 - ((ch39 + ch40)/2) Label FC2',   'nch27 = ch27 - ((ch39 + ch40)/2) Label F4',...
%         'nch28 = ch28 - ((ch39 + ch40)/2) Label F8',   'nch29 = ch29 - ((ch39 + ch40)/2) Label AF4',   'nch30 = ch30 - ((ch39 + ch40)/2) Label Fp2',...
%         'nch31 = ch31 - ((ch39 + ch40)/2) Label Fz',   'nch32 = ch32 - ((ch39 + ch40)/2) Label Cz',    'nch33 = ch33 - ((ch39 + ch40)/2) Label FCz',...
%         'nch34 = ch34 - ((ch39 + ch40)/2) Label Iz',   'nch35 = ch35 - ((ch39 + ch40)/2) Label VEO+',  'nch36 = ch36 - ((ch39 + ch40)/2) Label VEO-',...
%         'nch37 = ch37 - ((ch39 + ch40)/2) Label HEOR', 'nch38 = ch38 - ((ch39 + ch40)/2) Label HEOL'}, 'ErrorMsg', 'popup', 'Warning', 'off' );
% 
% EEG = pop_eegchanoperator(EEG, {...
%         'nch1 = ch1 Label Fp1',  'nch2 = ch2 Label AF3',  'nch3 = ch3 Label F7',  'nch4 = ch4 Label F3',...
%         'nch5 = ch5 Label FC1',  'nch6 = ch6 Label FC5',  'nch7 = ch7 Label T7',  'nch8 = ch8 Label C3',...
%         'nch9 = ch9 Label CP1',  'nch10 = ch10 Label CP5',  'nch11 = ch11 Label P7',  'nch12 = ch12 Label P3',...
%         'nch13 = ch13 Label Pz',  'nch14 = ch14 Label PO3',  'nch15 = ch15 Label O1',  'nch16 = ch16 Label Oz',...
%         'nch17 = ch17 Label O2',  'nch18 = ch18 Label PO4',  'nch19 = ch19 Label P4',  'nch20 = ch20 Label P8',...
%         'nch21 = ch21 Label CP6',  'nch22 = ch22 Label CP2',  'nch23 = ch23 Label C4',  'nch24 = ch24 Label T8',...
%         'nch25 = ch25 Label FC6',  'nch26 = ch26 Label FC2',  'nch27 = ch27 Label F4',  'nch28 = ch28 Label F8',...
%         'nch29 = ch29 Label AF4',  'nch30 = ch30 Label Fp2',  'nch31 = ch31 Label Fz',  'nch32 = ch32 Label Cz',...
%         'nch33 = ch33 Label FCz',  'nch34 = ch34 Label Iz',  'nch35 = ch35-ch36 Label VEOG',  'nch36 = ch37-ch38 Label HEOG'},...
%         'ErrorMsg', 'popup', 'Warning', 'off' );

EEG = pop_basicfilter(EEG, 1:EEG.nbchan,...
		'Boundary', 'boundary',...	% Boundary events
		'Cutoff', [ 0.1 30],...		% High and low cutoff
		'Design', 'butter',...		% IIR Butterworth filter
		'Filter', 'bandpass',...	% Bandpass filter type
		'Order',  2,...				% Filter order
		'RemoveDC', 'on' );			% Remove DC offset

    % 9. Reload channel locations
EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
%eeglab redraw;    

	%EEG = pop_editset(EEG, 'setname', [subName{iSubject} '_ChopResampFilt']);
	%EEG = pop_saveset(EEG, 'filename',[subName{iSubject} '_ChopResampFilt.set'], 'filepath', ongoing_dataset_savepath);

    % ===== Steps 11-14: remove VEOG/HEOG, detect bad channels, reload dataset above with full channels, remove bad channels, save dataset, interpolate removed channels =====
    
    % 11. Automatic bad channel detection/rejection using clean_rawdata
    %   11a. First remove VEOG/HEOG BEFORE bad channel detection/removal: Final Channel list: 0-34 = SCALP chans
    %EEG = pop_select(EEG, 'nochannel',{'VEOG','HEOG'}); 
    %   11b. Reload channel locations
    %EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    %eeglab redraw;
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
    %EEG = pop_loadset('filename',[subName{iSubject} '_ChopResampFilt.set'], 'filepath', ongoing_dataset_savepath);
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
    %eeglab redraw;
    %   12f. Actually remove the bad channels using badChansList
    for channel = 1:length(badChansList)
        EEG = pop_select(EEG, 'nochannel',{badChansList{channel}});
    end
    %eeglab redraw;

    % 13. Edit dataset name and save preprocessed .set/.fdt file AFTER removing channels
	%EEG = pop_editset(EEG, 'setname', [subName{iSubject} '_ChopResampFilt_removedchans']);
	%EEG = pop_saveset(EEG, 'filename',[subName{iSubject} '_ChopResampFilt_removedchans.set'], 'filepath', ongoing_dataset_savepath);

    % 14. Interpolate bad channels, resave dataset
    EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
    %eeglab redraw;
    EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);
    %eeglab redraw;
	%EEG = pop_editset(EEG, 'setname', [subName{iSubject} '_ChopResampFilt_Interp']);
	%EEG = pop_saveset(EEG, 'filename',[subName{iSubject} '_ChopResampFilt_Interp.set'], 'filepath', ongoing_dataset_savepath);
    %eeglab redraw;


end
