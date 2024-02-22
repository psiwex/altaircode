function [EEG] = basePreprocessingSoar(EEG,bnds)
%John LaRocco


%--------------------------------------------------------------------------
% basePreprocessingSoar

% Last updated: Jan 2024, J. LaRocco

% Details: Function performs preprocessing with baseline removal and detrending. 

% Usage: [EEG] = basePreprocessingSoar(EEG)

% Input:
%  EEG: a struct of EEG data. 

% Output:
% EEG: a struct of final EEG data. 

%--------------------------------------------------------------------------

%%Preprocessing
%% Where the file is preprocessed.     
%snr0 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_clean_rawdata(EEG,'asr',1);
%EEG = eeg_checkset(EEG); clc;
EEG = removeTrend(EEG); clc;   
EEG = soarPreproc(EEG,bnds); clc;

EEG = pop_eegfiltnew(EEG,bnds(1),bnds(2)); clc;
%snr1 = snrCompare(EEG.data,bnds,EEG.srate);
x=EEG.data;
x=smoothdata(x);
EEG.data=x;
    EEG = eeg_checkset(EEG); clc;
    
    
end