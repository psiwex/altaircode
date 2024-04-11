%close all;
clear; 
clc;
% Bin 1
% Incorrect Response
% .{9;10}
% 
% Bin 2
% Correct Response
% .{3;4}
% 
% Bin 3
% Congruent Stimulus
% .{1}
% 
% Bin 4
% Incongruent Stimulus
% .{2}
% % bin1
load('ernN1.mat','e1');
load('ernN2.mat','e2');
load('ernN3.mat','e3');
load('ernN4.mat','e4');

load('ernFileNames.mat','filzList');
load('ernFileNums.mat','fileNums');


load('OSU-00002-04B-01-ERN.bdf_kukri_ern.mat')
x=EEG.data;
 
% ern1=squeeze(x(:,:,1));
% ern2=squeeze(x(:,:,2));
% ern3=squeeze(x(:,:,3));
% ern4=squeeze(x(:,:,4));

subSel=1;


for subSel=1:length(fileNums)
ern1=e1{subSel};
ern2=e2{subSel};
ern3=e3{subSel};
ern4=e4{subSel};

fName=filzList{subSel};
% ern1=mean(ern1);
% ern2=mean(ern2);
% ern3=mean(ern3);
% ern4=mean(ern4);

%% ern parameters

winLength=1;
preLength=.5;
chanLim=48;
% channel fcz:
chanSel=41;
chanSel=3;
%chanSel=38;

%chanSel=1;
%chanSel=21;

EEG.srate=256;
totalLength=(EEG.srate*(preLength+winLength))+1;

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
legend('Correct','Error')
hold off;

saveas(figureHandle,['ernChan' num2str(chanSel) 'FromSub' num2str(subSel) '.jpg']);


ern=mean(ern1);
crn=mean(ern2);
figureHandle2=figure;
xPnts=linspace(-(preLength),(winLength),length(ern));
plot(xPnts,(crn))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(ern))
legend('Correct','Error')
hold off;
saveas(figureHandle2,['ernChanAveragedFromSub' num2str(subSel) '.jpg']);

close all;
end
