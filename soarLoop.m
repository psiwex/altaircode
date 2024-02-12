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
winLength=.5;
preLength=.5;

[epochCells,meanCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=ernEventEpochs(EEG,eventCodes,lern,preLength,winLength);

meanEeg=mean(meanCells);
xPnts=linspace(0,round(winLength*EEG.srate),length(meanEeg));


% error rates
eventCodes=[10, 11];
[ernEpochCells,ernMeanCells,~,~,~,~,~]=ernEventEpochs(EEG,eventCodes,lern,preLength,winLength);
meanErnEeg=mean(ernMeanCells);

eventCodes=[3, 4];
[crnEpochCells,crnMeanCells,~,~,~,~,~]=ernEventEpochs(EEG,eventCodes,lern,preLength,winLength);
meanCrnEeg=mean(crnMeanCells);

% only after stimuli appears
meanErnEeg=meanErnEeg(:,round(winLength*EEG.srate));
meanCrnEeg=meanCrnEeg(:,round(winLength*EEG.srate));

% plot figures
figure();

plot(xPnts,meanEeg)
ylabel('Voltage (uV)')
xlabel('Time (s)')
% endPoint=min([samples,sTimes(end)])
% find the doors arrow stim
% find the flanker response code


xPnts=linspace(0,round(winLength*EEG.srate),length(meanErnEeg));
plot(xPnts,meanErnEeg)
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,meanCrnEeg)
legend('Error','Correct')
hold off;
xx=EEG.chanlocs;
splName='STUDY_headplot.spl';
xx = readlocs('Standard-10-10-Cap47.ced');
headplot('setup', xx, splName)

figure; 
%headplot(EEG.data, splName)
headplot(crnMeanCells, splName)
%% lst
clc;
clear EEG;
load('OSU-00002-04B-01-LST.bdf.mat')
winLength=1;
eventCodes=[6];
eventCodes=[11];
[~,meanCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=soarEventEpochs(EEG,eventCodes,llst,winLength);
lstWin=mean(meanCells);

eventCodes=[7];
eventCodes=[12];
[~,meanCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=soarEventEpochs(EEG,eventCodes,llst,winLength);
lstLos=mean(meanCells);

figure();
xPnts=linspace(0,1,length(lstWin));
plot(xPnts,lstWin)
ylabel('Voltage (uV)')
xlabel('Time (s)')
hold on;
plot(xPnts,lstLos)
legend('Win','Loss')
hold off;

splName='STUDY_headplot.spl';
xx = readlocs('Standard-10-10-Cap47.ced');
headplot('setup', xx, splName)

figure; 
headplot(EEG.data, splName)
