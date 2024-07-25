%close all;
clear; 
clc;
plotChan='FCz';
% Bin 1
% Loss Trial
% .{6}
% 
% Bin 2
% Win Trial
% .{7}
% 

load('erplstsNames.mat','erplstNames');
%load('OSU-00002-04B-01-ERN.bdf_kukri_ern.mat')
%x=EEG.data;
 
% ern1=squeeze(x(:,:,1));
% ern2=squeeze(x(:,:,2));
% ern3=squeeze(x(:,:,3));
% ern4=squeeze(x(:,:,4));

winLength=1;
preLength=.2;
chanLim=48;
% channel fcz:
chanSel=41;
chanSel=31;
%chanSel=38;

%chanSel=1;
%chanSel=21;

EEG.srate=256;
totalLength=(EEG.srate*(preLength+winLength))+1;
subSel=1;

outEx='_kukri_lst.mat';
for subSel=1:length(erplstNames)
sub2Load=erplstNames{subSel};

outName=append(sub2Load,outEx);
load(outName);
    %ERPS=erperns(subSel);
x=EEG.data;
las=EEG.chanlocs;
%labs=las.labels;
chanValues={};
myfield=squeeze(struct2cell(las));
for i=1:length(las)
chanValues{i}=myfield{1,i};
end

idx = strfind(chanValues,plotChan);

for iss=1:length(las)
y1=idx{iss};
    if y1==1
chanSel=iss;
end
end
%firstabc = find( plotChan, 1 );



fName=erplstNames{subSel};
index = strfind(fName, '\');

fName=fName((index(end)+1):end);

ern1=squeeze(x(:,:,1));
ern2=squeeze(x(:,:,2));
ern3=squeeze(x(:,:,3));
ern4=squeeze(x(:,:,4));
%     ern1=e1{subSel};
% ern2=e2{subSel};
% ern3=e3{subSel};
% ern4=e4{subSel};

%fName=filzList{subSel};
% ern1=mean(ern1);
% ern2=mean(ern2);
% ern3=mean(ern3);
% ern4=mean(ern4);

%% ern parameters



% accuracy and response time
%finalMean=mean(ernAcc);
corRtErn=0;
incRtErn=0;

lwrBnd=round(preLength*EEG.srate);
searchBnd=round(1.1*EEG.srate);

means=mean(ern1(:,lwrBnd:searchBnd),2);
maxs=max(abs(ern1(:,lwrBnd:searchBnd))')';
stds=std(ern1(:,lwrBnd:searchBnd)')';

%% figures 
% ern
% channel fcz is 38
ern=ern1(chanSel,:);
crn=ern2(chanSel,:);
figureHandle=figure;
xPnts=linspace(-(preLength),(winLength),length(ern));
plot(xPnts,(crn))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(ern))
legend('Loss','Win')
hold off;

%saveas(figureHandle,[fName 'lstChanGrat' num2str(chanSel) 'FromSub' num2str(subSel) '.jpg']);


% ern=mean(ern1);
% crn=mean(ern2);
% figureHandle2=figure;
% xPnts=linspace(-(preLength),(winLength),length(ern));
% plot(xPnts,(crn))
% ylabel('Voltage (uV)')
% xlabel('Time (ms)')
% hold on;
% plot(xPnts,(ern))
% legend('Loss','Win')
% hold off;
%saveas(figureHandle2,[fName 'lstChanWithICA2AveragedFromSub' num2str(subSel) '.jpg']);

close all;
end
