clear;
clc;
tic;

bnds=[.1,40];
subst='.bdf';
outEx='.mat';
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';

numErn=1;
numLst=1;
numNpu=1;

raw_bdf_loadpath = dirName;

raw_dataset_savepath = dirName;
ongoing_dataset_savepath = dirName;

processed_dataset_savepath = strcat(dirName,'\Completed\');

erpset_savepath= strcat(dirName,'\erpLabs\');
raw_eventlist_savepath= strcat(dirName,'\eventList\');

processed_eventlist_savepath= strcat(dirName,'\procEventList\');

binlisterPathErn = 'C:\Users\John\Documents\MATLAB\soarEtl\currentSoar\GorkaBinlister.txt';
binListerPathLst = 'C:\Users\John\Documents\MATLAB\soarEtl\currentSoar\LstBinlister.txt';
binListerPathNpu = 'C:\Users\John\Documents\MATLAB\soarEtl\currentSoar\NpuBinlister.txt';

% channelLocationFile: this path is found in your eeglab dipfit plugin folder: eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';

xx=readlocs(channelLocationFile);

namesErn={};
namesLst={};
namesNpu={};

fName='OSU-00001-04B-01';
nName=strcat(fName,'-NPU.bdf');
lName=strcat(fName,'-LST.bdf');
eName=strcat(fName,'-ERN.bdf');

outEx2='ProcessedEpochs.mat';

[EEGe,ERPe,erne] = altairErnPreproc(eName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binlisterPathErn,channelLocationFile);
[EEGl,ERPl,ernl] = altairDoorsPreproc(lName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPathLst,channelLocationFile);
[EEGn,ERPn,ernn] = altairNpuPreproc(nName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPathNpu,channelLocationFile);

[epochsAcceptedPercente] = altairAcceptedEpochs(EEGe);
EEGe.epochsAcceptedPercent=epochsAcceptedPercente;

[epochsAcceptedPercentl] = altairAcceptedEpochs(EEGl);
EEGl.epochsAcceptedPercent=epochsAcceptedPercentl;

[epochsAcceptedPercentn] = altairAcceptedEpochs(EEGn);
EEGn.epochsAcceptedPercent=epochsAcceptedPercentn;

eOut=strcat(eName,outEx2);
lOut=strcat(lName,outEx2);
nOut=strcat(nName,outEx2);

save(eOut,'EEGe')
save(lOut,'EEGl')
save(nOut,'EEGn')

namesErn{numErn}=eOut;
namesLst{numLst}=lOut;
namesNpu{numNpu}=nOut;
