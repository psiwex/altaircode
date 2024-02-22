clear;
clc;
tic;

bnds=[.1,40];

[EEG, command] = pop_readbdf('OSU-00001-04B-01-ERN.bdf'); 
snra0 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_clean_rawdata(EEG,'asr',1);
EEG = eeg_checkset(EEG); clc;
EEG = removeTrend(EEG); clc;   
EEG = soarPreproc(EEG); clc;
snra1 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_eegfiltnew(EEG,bnds(1),bnds(2)); clc;
snra2 = snrCompare(EEG.data,bnds,EEG.srate);


[EEG, command] = pop_readbdf('OSU-00001-04B-01-LST.bdf'); 
snrb0 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_clean_rawdata(EEG,'asr',1);
EEG = eeg_checkset(EEG); clc;
EEG = removeTrend(EEG); clc;   
EEG = soarPreproc(EEG); clc;
snrb1 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_eegfiltnew(EEG,bnds(1),bnds(2)); clc;
snrb2 = snrCompare(EEG.data,bnds,EEG.srate);

[EEG, command] = pop_readbdf('OSU-00001-04B-01-NPU.bdf'); 
snrc0 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_clean_rawdata(EEG,'asr',1);
EEG = eeg_checkset(EEG); clc;
EEG = removeTrend(EEG); clc;   
EEG = fastPreproc(EEG); clc;
snrc1 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_eegfiltnew(EEG,bnds(1),bnds(2)); clc;
snrc2 = snrCompare(EEG.data,bnds,EEG.srate);


[EEG, command] = pop_readbdf('OSU_00001_01_01_ERN.bdf'); 
snrd0 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_clean_rawdata(EEG,'asr',1);
EEG = eeg_checkset(EEG); clc;
EEG = removeTrend(EEG); clc;   
EEG = fastPreproc(EEG); clc;
snrd1 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = pop_eegfiltnew(EEG,bnds(1),bnds(2)); clc;
snrd2 = snrCompare(EEG.data,bnds,EEG.srate);