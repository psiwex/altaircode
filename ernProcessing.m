clear;
clc;
tic;

bnds=[.1,40];

winLen=1;
chanPercent=[];

fName='OSU-00001-04B-01-ERN.bdf';
subst='.bdf';
outEx='.mat';
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
[sub] = subdir(dirName);

metaData=struct2table(sub);
fileList=metaData.name;
ii=fileList(1);
for ij=1:length(fileList)
ij/length(fileList);
    ii=fileList(ij);
fName=ii{1};
tf = endsWith(fName,subst);
if tf ~= (0)
    try
outName=append(fName,outEx);
outName
%load(outName,'EEG')
%EEG = eeg_checkset(EEG); clc;
    catch
chanPer=1;
    end
end
%chanPercent=[chanPercent; chanPer];

%save('soarSnrResample5.mat','chanPercent');

end
%finalMean=mean(chanPercent);
%truPer=chanPercent(find(chanPercent~=1));
%trueMean=mean(truPer);


% Flanker/ERN Task:
% ERROR TRIALS = 9 and 10
% CORRECT TRIALS = 3 and 4
% 
% LST/Doors Task:
% WIN TRIAL = 7
% LOSS TRIAL = 6


toc;
load('OSU-00002-04B-01-ERN.bdf.mat')
% lst and ern

%npu load
f2='OSU_00001_01_01-ERN.log';
ern = readtable(f2,'NumHeaderLines',5,ReadRowNames=true);

f3='OSU_00001_01_01-LST.log';
lst = readtable(f3,'NumHeaderLines',5,ReadRowNames=true);

f4='OSU_00001_01_01-NPU.log';
npu = readtable(f4,'NumHeaderLines',7,ReadRowNames=true);

lern=table2cell(ern);
llst=table2cell(lst);
lnpu=table2cell(npu);

eventCodes=[3, 4];
[ernCorIndexPnts,corErnTimes,~,~,corErnRts]=soarEventFinder(EEG,eventCodes,lern);


eventCodes=[10, 11];
[ernIncIndexPnts,incErnTimes,~,~,incErnRts]=soarEventFinder(EEG,eventCodes,lern);

totalErnEvents=length(ernIncIndexPnts)+length(ernCorIndexPnts);
totalErnAccuracy=length(ernCorIndexPnts)./totalErnEvents;
eventCodes=[3, 4, 10, 11];
winLength=1;
[epochCells,meanCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=soarEventEpochs(EEG,eventCodes,lern,winLength);

meanEeg=mean(meanCells);
xPnts=linspace(0,1,length(meanEeg));
figure();

plot(xPnts,meanEeg*1000)
ylabel('Voltage (mV)')
xlabel('Time (s)')
% endPoint=min([samples,sTimes(end)])
% find the doors arrow stim
% find the flanker response code



