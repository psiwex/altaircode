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

binListerPath = 'C:\Users\John\Documents\MATLAB\soarEtl\currentSoar\LstBinlister.txt';
% channelLocationFile: this path is found in your eeglab dipfit plugin folder: eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
%channelLocationFile = 'C:\Users\glaze\Documents\MatLabPrograms\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';


%fName='OSU-00001-04B-01-LST.bdf';
subst2='lst.bdf';
subst='LST.bdf';
outEx='_kukri_lst.mat';
outEx2='_kukri_lst_erp.mat';
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
[sub] = subdir(dirName);
erplsts={};
erplstNames={}
erpernNum=1;
erpernFileNum=1;
erplstFiles={};
fNameList={};
metaData=struct2table(sub);
fileList=metaData.name;
% ii=fileList(1);
%load('erpernsFiles.mat','erpernsFiles');
%fileList=erplstFiles;
erpernNames={};
for ij=1:length(fileList)
ij/length(fileList)
    ii=fileList(ij);
fName=ii{1};
fNameList{ij}=fName;
tf = endsWith(fName,subst);
tf2 = endsWith(fName,subst2);

if tf ~= (0)
        erplstFiles{erpernFileNum}=fName;
        erpernFileNum=erpernFileNum+1;
outName=append(fName,outEx);
try
%[EEG,ERP,erns] = altairLstPreproc(fName,binListerPath,channelLocationFile);
    [EEG,ERP,erns] = altairDoorsPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile)
%[EEG,ERP,erns] = altairLstPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile)

close all;
erplstNames{erpernNum}=fName;
erpernNum=erpernNum+1;
save(outName,'EEG')
outName

catch
end


if tf2 ~= (0)
        erplstFiles{erpernFileNum}=fName;
        erpernFileNum=erpernFileNum+1;
outName=append(fName,outEx);
try
[EEG,ERP,erns] = altairDoorsPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile)
%[EEG,ERP,erns] = altairLstPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile);
%[EEG,ERP,erns] = altairDoorsPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binlister_loadpath,channelLocationFile);
close all;
erplstNames{erpernNum}=fName;
erpernNum=erpernNum+1;
save(outName,'EEG')
outName

catch
end

end

end
%load(outName,'EEG')
%EEG = eeg_checkset(EEG); clc;
%save(outName,'EEG')
%snr1 = snrCompare(EEG.data,bnds,EEG.srate);


%end
%chanPercent=[chanPercent; chanPer];

%save('soarSnrResample5.mat','chanPercent');

end
%finalMean=mean(chanPercent);
%truPer=chanPercent(find(chanPercent~=1));
%trueMean=mean(truPer);

save('erplstsNames.mat','erplstNames');

toc;

% l1=length(erplstNames);
% l2=length(erplstNames2);
% 
% erplstNames0=erplstNames2;
% 
% erplstNames2{52}=erplstNames{1};
% erplstNames2{53}=erplstNames{2};
% erplstNames2{54}=erplstNames{3};
% erplstNames2{55}=erplstNames{4};
% erplstNames2{56}=erplstNames{5};

