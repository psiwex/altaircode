clear;
clc;
tic;
% good subject: OSU-0001-04B-01-ERN
bnds=[.1,30];
 
raw_bdf_loadpath = 'C:\Users\John\Documents\MATLAB\soarData\';

raw_dataset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';
ongoing_dataset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';

processed_dataset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\Completed\';

%erpset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';
erpset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\erpLabs\';
 
raw_eventlist_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';
processed_eventlist_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';

binlister_loadpath = 'C:\Users\John\Documents\MATLAB\soarEtl\GorkaBinlister.txt';
% channelLocationFile: this path is found in your eeglab dipfit plugin folder: eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
%channelLocationFile = 'C:\Users\glaze\Documents\MatLabPrograms\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';


%fName='OSU-00001-04B-01-ERN.bdf';
subst='.bdf';
outEx='_kukri_ern.mat';
outEx2='_kukri_ern_erp.mat';
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
[sub] = subdir(dirName);
erperns={};
erpernNum=1;
erpernFileNum=1;
erpernsFiles={};
fNameList={};
metaData=struct2table(sub);
fileList=metaData.name;
ii=fileList(1);
load('erpernsFiles.mat','erpernsFiles');
fileList=erpernsFiles;
for ij=1:length(fileList)
ij/length(fileList)
    ii=fileList(ij);
fName=ii{1};
fNameList{ij}=fName;
tf = endsWith(fName,subst);
if tf ~= (0)
    try
        erpernsFiles{erpernFileNum}=fName;
        erpernFileNum=erpernFileNum+1;
%  EEG = pop_biosig(fName);
%    % [EEG, command] = pop_readbdf(fName); 
% snr0 = snrCompare(EEG.data,bnds,EEG.srate);
% EEG = altairPreproc(EEG); 
%[EEG,ERP,erns] = altairPreproc(fName,raw_bdf_loadpath,raw_dataset_savepath,ongoing_dataset_savepath,processed_dataset_savepath,erpset_savepath,raw_eventlist_savepath,processed_eventlist_savepath,binlister_loadpath,channelLocationFile);

erperns{erpernNum}=ERP;
erpernNum=erpernNum+1;
outName=append(fName,outEx)
save(outName,'EEG')
outName2=append(fName,outEx2)
save(outName2,'EEG')
%load(outName,'EEG')
%EEG = eeg_checkset(EEG); clc;
%save(outName,'EEG')
%snr1 = snrCompare(EEG.data,bnds,EEG.srate);

    catch
%chanPer=1;
    end
end
%chanPercent=[chanPercent; chanPer];

%save('soarSnrResample5.mat','chanPercent');

end
%finalMean=mean(chanPercent);
%truPer=chanPercent(find(chanPercent~=1));
%trueMean=mean(truPer);

save('erperns.mat','erperns');

toc;