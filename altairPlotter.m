close all;
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
% bin1
load('ernM1.mat','ern1');

% bin2
load('ernM2.mat','ern2');

% bin3
load('ernM3.mat','ern3');

% bin4
load('ernM4.mat','ern4');


load('OSU-00002-04B-01-ERN.bdf.mat')

%% ern parameters

winLength=.5;
preLength=1;
chanLim=48;
% channel fcz:
chanSel=41;
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
figure;
xPnts=linspace(-(preLength),(winLength),length(ern));
plot(xPnts,detrend(crn))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,detrend(ern))
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
headplot(ern1(:,lwrBnd:searchBnd), splName)


% ern
% channel fcz is 38
ern=ern3(chanSel,:);
crn=ern4(chanSel,:);
figure;
xPnts=linspace(-(preLength),(winLength),length(ern));
plot(xPnts,crn)
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,ern)
legend('Congruent','Incongruent')
hold off;


ern=ern1(chanSel,(round(preLength*EEG.srate):end));
crn=ern2(chanSel,(round(preLength*EEG.srate):end));
figure;
xPnts=linspace(0,(winLength),length(ern));
plot(xPnts,detrend(crn))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,detrend(ern))
legend('Correct','Error')
hold off;

