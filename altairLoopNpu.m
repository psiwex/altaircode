clear;
clc;
tic;
% good subject: OSU-0001-04B-01-NPU
%Adapting our existing pipeline, the steps I plan to implement for NPU startle are:
%-You average about -50 ms prior to stimulus.
%-You filter between 28 Hz high-pass filer, rectified, and then smoothed using a 40 Hz low-pass filter.
%-You look for peak amplitude 20-150-ms after stimulus.

%I presume plotting this with -50 ms to 200 ms might be suitable.

%file name: OSU-00009-05A-NPU.bdf_kukri_npu.mat

bnds=[.1,30];
 
raw_bdf_loadpath = 'C:\Users\John\Documents\MATLAB\soarData\';

raw_dataset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';
ongoing_dataset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';

processed_dataset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\Completed\';


%erpset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';
erpset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\erpLabs\';
 
raw_eventlist_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';
processed_eventlist_savepath = 'C:\Users\John\Documents\MATLAB\soarData\';

binListerPath = 'C:\Users\John\Documents\MATLAB\soarEtl\currentSoar\NpuBinlister.txt';
% channelLocationFile: this path is found in your eeglab dipfit plugin folder: eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
%channelLocationFile = 'C:\Users\glaze\Documents\MatLabPrograms\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';


%fName='OSU-00001-04B-01-LST.bdf';
subst2='npu.bdf';
subst='NPU.bdf';
outEx='_kukri_npu.mat';
outEx2='_kukri_npu_erp.mat';
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
[sub] = subdir(dirName);
erpnpus={};
erpnpuNames={};
erpernNum=1;
erpernFileNum=1;
erpnpuFiles={};
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
        erpnpuFiles{erpernFileNum}=fName;
        erpernFileNum=erpernFileNum+1;
outName=append(fName,outEx);
try
%[EEG,ERP,erns] = altairLstPreproc(fName,binListerPath,channelLocationFile);
    [EEG,ERP,erns] = altairNpuPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile)
%[EEG,ERP,erns] = altairLstPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile)

close all;
erpnpuNames{erpernNum}=fName;
erpernNum=erpernNum+1;
save(outName,'EEG')
outName

catch
end


if tf2 ~= (0)
        erpnpuFiles{erpernFileNum}=fName;
        erpernFileNum=erpernFileNum+1;
outName=append(fName,outEx);
try
[EEG,ERP,erns] = altairNpuPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile)
%[EEG,ERP,erns] = altairLstPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binListerPath,channelLocationFile);
%[EEG,ERP,erns] = altairDoorsPreproc(fName,raw_dataset_savepath,ongoing_dataset_savepath,erpset_savepath,binlister_loadpath,channelLocationFile);
close all;
erpnpuNames{erpernNum}=fName;
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

save('erpnpuNames.mat','erpnpuNames');

toc;


