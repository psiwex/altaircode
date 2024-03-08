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
EEG = pop_resample(EEG, 256, 0.8, 0.4); % BioSemi
EEG = pop_chanedit(EEG, 'lookup', channelLocationFile);
EEG = pop_basicfilter(EEG, 1:EEG.nbchan, 'Boundary', 'boundary','Cutoff', [ 0.1 30],'Design', 'butter','Filter', 'bandpass','Order',  2,'RemoveDC', 'on' );	
EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);

    %   11c. Automatically detect and remove bad SCALP chans using clean_rawdata default parameters
    EEG = pop_clean_rawdata(EEG,...
        'FlatlineCriterion', 5,...      % Maximum tolerated flatline duration in seconds (Default: 5)
        'ChannelCriterion', 0.85,...    % Minimum channel correlation with neighboring channels (default: 0.85)
        'LineNoiseCriterion', 4,...     % Maximum line noise relative to signal in standard deviations (default: 4)
        'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');

    trimChans = {};
    for channel = 1:EEG.nbchan
        trimChans{end+1} = EEG.chanlocs(channel).labels;
    end
  
    trimChans{end+1} = 'VEOG';
    trimChans{end+1} = 'HEOG';

    originalEEG = EEG;
   
    allChans = {};
    for channel = 1:EEG.nbchan
        allChans{end+1} = EEG.chanlocs(channel).labels;
    end
   
    badChansList = {};
    for channel = 1:length(allChans)
        badChan = strcmp(trimChans, allChans(channel));
        if sum(badChan) == 0
            badChansList{end+1} = allChans{channel};
        end
    end

    for channel = 1:length(badChansList)
        EEG = pop_select(EEG, 'nochannel',{badChansList{channel}});
    end
EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);

%EEG = pop_gratton(EEG, 35, 'chans', 1:EEG.nbchan);
%EEG = pop_gratton(EEG, 36, 'chans', 1:EEG.nbchan);	

EEG = pop_select(EEG, 'nochannel',{'VEOG','HEOG'}); 
EEG = pop_chanedit(EEG, 'lookup',channelLocationFile);

end
