clear;
clc;
tic;

subst='.bdf';

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

subList2={'EEG_40001-01_01-15','EEG_40001-02_01-15','EEG_40001-03_01-15','EEG_40003-01_01-15','EEG_40003-02_01-15','EEG_40007-01_01-15','EEG_40007-02_01-15','EEG_40008-01_01-15','EEG_40008-02_01-15','EEG_40008-04_01-15','EEG_40009-01_01-15','EEG_40009-02_01-15','EEG_40011-01_01-15','EEG_40011-02_01-15','EEG_40012-01_01-15','EEG_40012-02_01-15','EEG_40013-02_01-15','EEG_40013-04_01-15','EEG_40014-01_01-15','EEG_40014-02_01-15','EEG_40014-03_01-15','EEG_40015-01_15','EEG_40018-01_01-15','EEG_40020-01_01-15','EEG_40021-01_01-15','EEG_40023-01_01-15','EEG_40025-02_01-15','EEG_40030-01_01-15'};
ernList={'15-40008-01_ERN.bdf','15-40008-02_ERN.bdf','15-40009-01_ERN.bdf','15-40009-02_ERN.bdf','15-40011-01_ERN.bdf','15-40011-02_ERN.bdf','15-40012-01_ERN.bdf','15-40012-02_ERN.bdf','15-40013-02_ERN.bdf','15-40013-04_ERN.bdf','15-40014-01_ERN.bdf','15-40014-02_ERN.bdf','15-40014-03_ERN.bdf','15-40015-01_ERN.bdf','15-40018-01_ERN.bdf','15-40020-01_ERN.bdf','15-40021-01_ERN.bdf','15-40023-01_ERN.bdf','15-40025-02_ERN.bdf','15-40030-01_ERN.bdf','SOAR_15-40001-01_ERN.bdf','SOAR_15-40001-02_ERN.bdf','SOAR_15-40001-03_ERN.bdf','SOAR_15-40003-01_ERN.bdf','SOAR_15-40003-02_ERN.bdf','SOAR_15-40007-01_ERN.bdf','SOAR_15-40007-02_ERN.bdf','SOAR_15-40008-04_ERN.bdf'};
lstList={'15-40008-02_LST.bdf','15-40009-01_LST.bdf','15-40009-02_LST.bdf','15-40011-01_LST.bdf','15-40011-02_LST.bdf','15-40012-01_LST.bdf','15-40012-02_LST.bdf','15-40013-04_LST.bdf','15-40014-01_LST.bdf','15-40014-02_LST.bdf','15-40014-03_LST.bdf','15-40015-01_LST.bdf','15-40018-01_LST.bdf','15-40020-01_LST.bdf','15-40021-01_LST.bdf','15-40023-01_LST.bdf','15-40030-01_LST.bdf','SOAR-15-40003-01_LST.bdf','SOAR_15-40001-01_LST.bdf','SOAR_15-40001-02_LST.bdf','SOAR_15-40001-03_LST.bdf','SOAR_15-40003-02_LST.bdf','SOAR_15-40007-01_LST.bdf','SOAR_15-40007-02_LST.bdf','SOAR_15-40008-04_LST.bdf'};
npuList={'15-40008-01_NPU.bdf','15-40008-02_NPU.bdf','15-40009-01_NPU.bdf','15-40009-02_NPU.bdf','15-40011-01_NPU.bdf','15-40011-02_NPU.bdf','15-40012-01_NPU.bdf','15-40012-02_NPU.bdf','15-40013-02_NPU.bdf','15-40013-04_NPU.bdf','15-40014-02_NPU.bdf','15-40014-03_NPU.bdf','15-40015-01_NPU.bdf','15-40018-01_NPU.bdf','15-40020-01_NPU.bdf','15-40021-01_NPU.bdf','15-40023-01_NPU.bdf','15-40025-02_NPU.bdf','15-40030-01_NPU.bdf','SOAR_15-40001-01_NPU.bdf','SOAR_15-40001-02_NPU.bdf','SOAR_15-40001-03_NPU.bdf','SOAR_15-40003-01_NPU.bdf','SOAR_15-40003-02_NPU.bdf','SOAR_15-40007-01_NPU.bdf','SOAR_15-40007-02_NPU.bdf','SOAR_15-40008-04_NPU.bdf'};
workLength=min([length(npuList),length(ernList),length(lstList),length(subList2)]);

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
fName='C:\Users\John\Documents\MATLAB\soarCinci\EEG_40001-01_01-15\RESOURCES\EEG\SOAR_15-40001-01\SOAR_15-40001-01';


nName=strcat(fName,'_NPU.bdf');
lName=strcat(fName,'_LST.bdf');
eName=strcat(fName,'_ERN.bdf');

outEx2='CinciProcessedEpochs.mat';


nVal=[];
lVal=[];
eVal=[];
sName={};

for ii=1:workLength
sName{ii}=subList2;
    
    nName=npuList{ii};
lName=lstList{ii};
eName=ernList{ii};

%% ern
try
[EEGe,ERPe,erne] = altairErnPreproc(eName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binlisterPathErn,channelLocationFile);
[epochsAcceptedPercente] = altairAcceptedEpochs(EEGe);
EEGe.epochsAcceptedPercent=epochsAcceptedPercente;
eOut=strcat(eName,outEx2);
save(eOut,'EEGe')
namesErn{numErn}=eOut;
numErn=numErn+1;

eVal(ii)=epochsAcceptedPercente;

catch
end

%% lst
try
[EEGl,ERPl,ernl] = altairDoorsPreproc(lName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPathLst,channelLocationFile);
[epochsAcceptedPercentl] = altairAcceptedEpochs(EEGl);
EEGl.epochsAcceptedPercent=epochsAcceptedPercentl;
lOut=strcat(lName,outEx2);
save(lOut,'EEGl')
namesLst{numLst}=lOut;
numLst=numLst+1;
lVal(ii)=epochsAcceptedPercentl;

catch
    
end

%% npu
try
[EEGn,ERPn,ernn] = altairNpuPreproc(nName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPathNpu,channelLocationFile);
[epochsAcceptedPercentn] = altairAcceptedEpochs(EEGn);
EEGn.epochsAcceptedPercent=epochsAcceptedPercentn;
nOut=strcat(nName,outEx2);
save(nOut,'EEGn')
namesNpu{numNpu}=nOut;
numNpu=numNpu+1;
nVal(ii)=epochsAcceptedPercentn;
catch
end


end





