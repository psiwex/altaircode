close all;
clear; 
clc;

load('ernAccSoar.mat','ernAcc');
load('ernRtCorSoar.mat','ernRtCor');
load('ernRtIncSoar.mat','ernRtInc');
load('meanErnESoar.mat','meanErnE');
load('meanCrnESoar.mat','meanCrnE');
load('meanErnCorSoar.mat','ernCorCells');
load('meanErnIncSoar.mat','ernIncCells');

load('meanLstWinsSoar.mat','meanWins');
load('meanLstLossSoar.mat','meanLoss');
load('meanLstWinCellSoar.mat','listWinCells');
load('meanLstLosCellSoar.mat','listLosCells');

load('OSU-00002-04B-01-ERN.bdf.mat')

%% ern parameters

winLength=.5;
preLength=.5;

totalLength=(EEG.srate*(preLength+winLength))+1;

% accuracy and response time
finalMean=mean(ernAcc);
corRtErn=0;
incRtErn=0;
for ji=1:length(ernRtInc)
nBlock=ernRtCor{ji};
nBlock0=ernRtInc{ji};

if isempty(nBlock)==false
vBlock=mean(nBlock);
corRtErn=mean(corRtErn+vBlock);
end


if isempty(nBlock0)==false
vBlock0=mean(nBlock0);
incRtErn=mean(incRtErn+vBlock0);
end

end

chanLim=39;
conErnEeg=zeros(chanLim,totalLength);
incErnEeg=zeros(chanLim,totalLength);

for ji=1:length(ernCorCells)
ernC=ernCorCells{ji};
if isempty(ernC)==false
    ernCrn=ernC;
vBlock1=mean(cell2mat(ernC'),3);
vBlock1=vBlock1(1:chanLim,1:totalLength);
conErnEeg=mean(conErnEeg+vBlock1);
end

ernI=ernIncCells{ji};

if isempty(ernI)==false
    ernInc=ernI;
    try
vBlock2=mean(cell2mat(ernI'),3);
    catch
vBlock2=mean(cell2mat(ernI(1)'),3);

try

    vBlock1=mean((ernC'),3);
end
    end
vBlock2=vBlock2(1:chanLim,1:totalLength);
incErnEeg=mean(incErnEeg+vBlock2);
end

end


%% lst parameters
winLength=1;
totalLengthLst=(EEG.srate*(winLength))+1;
winLstEeg=zeros(chanLim,totalLength);
losLstEeg=zeros(chanLim,totalLength);

for ji=1:length(listWinCells)
ernC=listWinCells{ji};
if isempty(ernC)==false
    lstWin=ernC;
    try
vBlock1=mean(cell2mat(ernC'),3);
    catch
        try
    vBlock1=mean((ernC'),3);
    vBlock1=vBlock1';
        catch
vBlock1=mean(cell2mat(ernC(1))',3);
end
    

    end

vBlock1=vBlock1(1:chanLim,1:totalLength);
winLstEeg=mean(winLstEeg+vBlock1);
end

ernC=listLosCells{ji};
if isempty(ernC)==false
    lstLos=ernC;
    try
     
vBlock1=mean(cell2mat(ernC'),3);
    catch
        try
    vBlock1=mean((ernC'),3);
    vBlock1=vBlock1';
        catch
vBlock1=mean(cell2mat(ernC(1))',3);
end
    

    end

vBlock1=vBlock1(1:chanLim,1:totalLength);
losLstEeg=mean(losLstEeg+vBlock1);
end

end
chanSel=39;

%% figures 
% ern
% channel fcz is 38
ernI=ernInc{1};
ernC=ernCrn{1};
figure;
xPnts=linspace(-round(preLength*EEG.srate),round(winLength*EEG.srate),totalLength);
plot(xPnts,ernI(chanSel,:))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,ernC(chanSel,:))
legend('Error','Correct')
hold off;

xx=EEG.chanlocs;
splName='STUDY_headplot.spl';
xx = readlocs('Standard-10-10-Cap47.ced');
headplot('setup', xx, splName)

figure; 
%headplot(EEG.data, splName)
headplot(ernI, splName)

% lst
xPnts=linspace(0,round(winLength*EEG.srate),length(winLstEeg));
figure();
plot(xPnts,winLstEeg)
ylabel('Voltage (uV)')
xlabel('Time (s)')
hold on;
plot(xPnts,losLstEeg)
legend('Win','Loss')
hold off;
