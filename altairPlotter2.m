close all;
clear; 
clc;

load('ernAccSoarKukri.mat','ernAcc');
load('ernRtCorSoarKukri.mat','ernRtCor');
load('ernRtIncSoarKukri.mat','ernRtInc');
load('meanErnESoarKukri.mat','meanErnE');
load('meanCrnESoarKukri.mat','meanCrnE');
load('meanErnCorSoarKukri.mat','ernCorCells');
load('meanErnIncSoarKukri.mat','ernIncCells');

load('meanLstWinsSoarKukri.mat','meanWins');
load('meanLstLossSoarKukri.mat','meanLoss');
load('meanLstWinCellSoarKukri.mat','listWinCells');
load('meanLstLosCellSoarKukri.mat','listLosCells');

load('OSU-00002-04B-01-ERN.bdf.mat')

%% ern parameters

winLength=.5;
preLength=.5;
chanLim=39;
% channel fcz:
chanSel=33;

totalLength=(EEG.srate*(preLength+winLength))+1;

% accuracy and response time
finalMean=mean(ernAcc);
corRtErn=0;
incRtErn=0;
ernInd=[];
ernInd2=[];
for ji=1:length(ernRtInc)
nBlock=ernRtCor{ji};
nBlock0=ernRtInc{ji};

if isempty(nBlock)==false
vBlock=mean(nBlock);
corRtErn=mean(corRtErn+vBlock);
ernInd=[ernInd; ji];
end

if isempty(nBlock0)==false
vBlock0=mean(nBlock0);
incRtErn=mean(incRtErn+vBlock0);
ernInd2=[ernInd2; ji];
end
end

ernInd0=unique([ernInd; ernInd2]);



conErnEeg=zeros(chanLim,totalLength);
incErnEeg=zeros(chanLim,totalLength);

for ji=1:length(ernInd0)
    % for correct
ernCNum=ernInd0(ji);
x=ernCorCells{ernCNum};
[~,numCells]=size(x);
[xx1,yy1]=size(x{1});
recept=zeros(xx1,yy1);
for jj=1:numCells
conv=x{jj};
recept=recept+conv;
end
recept=recept/numCells;
recept=recept(1:chanLim,1:totalLength);
conErnEeg=conErnEeg+recept;


% for incorrect
ernENum=ernInd0(ji);
x=ernIncCells{ernENum};
[~,numCells0]=size(x);
[xx1,yy1]=size(x{1});
recept=zeros(xx1,yy1);
for jj=1:numCells0
conv=x{jj};
recept=recept+conv;
end
recept=recept/numCells0;
recept=recept(1:chanLim,1:totalLength);
incErnEeg=incErnEeg+recept;

end
conErnEeg=conErnEeg/length(ernInd0);
incErnEeg=incErnEeg/length(ernInd0);


%% lst parameters
winLength=1;
totalLengthLst=(EEG.srate*(winLength))+1;
winLstEeg=zeros(chanLim,totalLength);
losLstEeg=zeros(chanLim,totalLength);

lstInd=[];
lstInd1=[];


for ji=1:length(listWinCells)
celTest=listWinCells{ji};
if isempty(celTest)==false
    lstInd=ji;
end

celTest=listLosCells{ji};
if isempty(celTest)==false
    lstInd1=ji;
end



end

lstInd0=unique([lstInd; lstInd1]);


for ji=1:length(lstInd0)
% wins
ernCNum=lstInd0(ji);
x=listWinCells{ernCNum};
x=x(1:chanLim,1:totalLength);
winLstEeg=winLstEeg+x;

% loss
ernCNum=lstInd0(ji);
x=listLosCells{ernCNum};
x=x(1:chanLim,1:totalLength);
losLstEeg=losLstEeg+x;

end


winLstEeg=winLstEeg/length(lstInd0);
losLstEeg=losLstEeg/length(lstInd0);

%% pretty up each
% ern cleanup

preBaseline=(EEG.srate*(preLength))+1;
% x1=conErnEeg(:,1:preBaseline);
% 
% x2=incErnEeg(:,1:preBaseline);
% for aa=1:chanLim
% x1(aa,1:preBaseline)=linspace(x1(aa,1),x1(aa,end),preBaseline);
% x2(aa,1:preBaseline)=linspace(x2(aa,1),x2(aa,end),preBaseline);
% 
% end

% x1=detrend(x1,1);
% x2=detrend(x2,1);
% x1=x1-mean(x1);
% x2=x2-mean(x2);
% x1=detrend(x1,2);
% x2=detrend(x2,2);
% 
% conErnEeg(:,1:preBaseline)=x1;
% incErnEeg(:,1:preBaseline)=x2;
% crn=conErnEeg(:,preBaseline:end);
% ern=incErnEeg(:,preBaseline:end);
% 
% ern=detrend(ern,1);
% crn=detrend(crn,1);
% 
% crn=crn/max(max(crn));
% ern=ern/max(max(ern));

% conErnEeg(:,preBaseline:end)=crn;
% incErnEeg(:,preBaseline:end)=ern;

% lst cleanup
winLstEeg=winLstEeg-mean(winLstEeg);
losLstEeg=losLstEeg-mean(losLstEeg);

%% figures 
% ern
% channel fcz is 38
ern=incErnEeg(:,preBaseline:end);
figure;
xPnts=linspace(-round(preLength*EEG.srate),round(winLength*EEG.srate),totalLength);
plot(xPnts,(conErnEeg(chanSel,:)))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(incErnEeg(chanSel,:)))
legend('Correct','Error')
hold off;

xx=EEG.chanlocs;
splName='STUDY_headplot.spl';
xx = readlocs('Standard-10-10-Cap47.ced');

channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
xx = readlocs(channelLocationFile);
headplot('setup', xx, splName)

figure; 
%headplot(EEG.data, splName)
headplot(ern, splName)

% lst
xPnts=linspace(0,round(winLength*EEG.srate),length(winLstEeg));
figure();
plot(xPnts,winLstEeg(chanSel,:))
ylabel('Voltage (uV)')
xlabel('Time (s)')
hold on;
plot(xPnts,losLstEeg(chanSel,:))
legend('Win','Loss')
hold off;
