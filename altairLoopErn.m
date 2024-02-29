clear;
clc;
tic;

bnds=[.1,40];
chanPercent=[];

fName='OSU-00001-04B-01-ERN.bdf';
subst='.bdf';
outEx='_kukri_ern.mat';
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
[sub] = subdir(dirName);

metaData=struct2table(sub);
fileList=metaData.name;
ii=fileList(1);
for ij=1:length(fileList)
ij/length(fileList)
    ii=fileList(ij);
fName=ii{1};
tf = endsWith(fName,subst);
if tf ~= (0)
    try

    [EEG, command] = pop_readbdf(fName); 
snr0 = snrCompare(EEG.data,bnds,EEG.srate);
EEG = altairPreproc(EEG); 

outName=append(fName,outEx);
save(outName,'EEG')
load(outName,'EEG')
EEG = eeg_checkset(EEG); clc;
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



toc;