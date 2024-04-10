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
%load('ernM1.mat','ern1');
load('goodErn1.mat','ern1');
% 
% % bin2
%load('ernM2.mat','ern2');
load('goodErn2.mat','ern2');
% 
% % bin3
%load('ernM3.mat','ern3');
load('goodErn3.mat','ern3');
% 
% % bin4
%load('ernM4.mat','ern4');
load('goodErn4.mat','ern4');


load('OSU-00002-04B-01-ERN.bdf_kukri_ern.mat')
x=EEG.data;
 
% ern1=squeeze(x(:,:,1));
% ern2=squeeze(x(:,:,2));
% ern3=squeeze(x(:,:,3));
% ern4=squeeze(x(:,:,4));



%% ern parameters

winLength=1;
preLength=.5;
chanLim=48;
% channel fcz:
chanSel=41;
chanSel=31;

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
plot(xPnts,(crn))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(ern))
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
plot(xPnts,(crn))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(ern))
legend('Correct','Error')
hold off;

%% compare all
figure;
e1=ern1(chanSel,:);
e2=ern2(chanSel,:);
e3=ern3(chanSel,:);
e4=ern4(chanSel,:);
xPnts=linspace(-500,1000,length(e1));
plot(xPnts,(e1))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(e2))
plot(xPnts,(e3))
plot(xPnts,(e4))
legend('Line1','Line2','Line3','Line4')
hold off;


figure;
x=mean(ern1);
xPnts=linspace(-500,1000,length(x));
plot(xPnts,x)
ylabel('Voltage (uV)')
xlabel('Time (ms)')

