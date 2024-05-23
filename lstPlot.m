close all; clear; clc;
load('lstSoarSingle.mat','EEG');


plotChan='FCz';

% Bin 1
% Loss Trial
% .{6}
% 
% Bin 2
% Win Trial
% .{7}
% 
% Bin 3
% Left Response
% .{11}
% 
% Bin 4
% Right Response
% .{12}


%load('OSU-00002-04B-01-ERN.bdf_kukri_ern.mat')
x=EEG.data;
 
ern1=squeeze(x(:,:,1));
ern2=squeeze(x(:,:,2));
ern3=squeeze(x(:,:,3));
ern4=squeeze(x(:,:,4));

winLength=.5;
preLength=.1;
chanLim=48;
% channel fcz:
chanSel=41;
chanSel=27;

%chanSel=38;

%chanSel=1;
%chanSel=21;

EEG.srate=256;
totalLength=(EEG.srate*(preLength+winLength))+1;
subSel=1;

x=EEG.data;
%for subSel=1:length(erperns)
%ERPS=erperns(subSel);
%x=ERPS{1}.bindata;
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



% fName=erpernNames{subSel};
% index = strfind(fName, '\');
% 
% fName=fName((index(end)+1):end);

ern1=squeeze(x(:,:,1));
ern2=squeeze(x(:,:,2));
ern3=squeeze(x(:,:,3));
ern4=squeeze(x(:,:,4));


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
los=ern1(chanSel,:);
win=ern2(chanSel,:);
figureHandle=figure;
xPnts=linspace(-(preLength),(winLength),length(win));
plot(xPnts,(los))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(win))
legend('Loss','Win')
hold off;

%saveas(figureHandle,[fName 'ernChan' num2str(chanSel) 'FromSub' num2str(subSel) '.jpg']);


los=mean(ern1);
win=mean(ern2);
figureHandle2=figure;
xPnts=linspace(-(preLength),(winLength),length(los));
plot(xPnts,(los))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(win))
legend('Loss','Win')
hold off;
%saveas(figureHandle2,[fName 'ernChanAveragedFromSub' num2str(subSel) '.jpg']);

%close all;
%end
