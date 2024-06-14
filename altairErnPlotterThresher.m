%close all;
clear; 
clc;
plotChan='FCz';
load('ernArtRejection.mat','ernArtRep');

mainVec=ernArtRep(:,3);
rejThres=.8;
vals=find(mainVec>rejThres);

mainVals=mainVec(vals);

%load('lstArtRejection.mat','lstArtRep');


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

load('erperns.mat','erperns')
load('erpernNames.mat','erpernNames');
%load('OSU-00002-04B-01-ERN.bdf_kukri_ern.mat')
%x=EEG.data;
 
% ern1=squeeze(x(:,:,1));
% ern2=squeeze(x(:,:,2));
% ern3=squeeze(x(:,:,3));
% ern4=squeeze(x(:,:,4));
ern=[];
crn=[];

winLength=1;
preLength=.5;
chanLim=48;
% channel fcz:
chanSel=41;
chanSel=31;
%chanSel=38;
outEx2='_kukri_ern_erp.mat';
%chanSel=1;
%chanSel=21;

EEG.srate=256;
totalLength=(EEG.srate*(preLength+winLength))+1;
subSelTrue=1;


% if any(subSel == vals )
%     disp('There is at least one value here.')
% else
%     disp('All values are not here.')
% end

for subSel=1:length(erpernNames)

    if any(subSel == vals )
fName=erpernNames{(subSel)};

strLoad=append(fName,outEx2);
try
load(strLoad)
x=EEG.data;
las=EEG.chanlocs;
    %ERPS=erperns(subSel);
%x=ERPS{1}.bindata;
%las=ERPS{1}.chanlocs;
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
subSelTrue=subSelTrue+1;
ern(subSelTrue,:)=ern1(chanSel,:);
crn(subSelTrue,:)=ern2(chanSel,:);

catch
end
    end
end
ee1=ern;
ee2=crn;
ern=mean(ern);
crn=mean(crn);

figureHandle=figure;
xPnts=linspace(-(preLength),(winLength),length(ern));
plot(xPnts,(crn))
ylabel('Voltage (uV)')
xlabel('Time (ms)')
hold on;
plot(xPnts,(ern))
legend('Correct','Error')
hold off;

%saveas(figureHandle,[fName 'ernChan' num2str(chanSel) 'FromSub' num2str(subSel) '.jpg']);


% ern=mean(ern1);
% crn=mean(ern2);
% figureHandle2=figure;
% xPnts=linspace(-(preLength),(winLength),length(ern));
% plot(xPnts,(crn))
% ylabel('Voltage (uV)')
% xlabel('Time (ms)')
% hold on;
% plot(xPnts,(ern))
% legend('Correct','Error')
% hold off;
%saveas(figureHandle2,[fName 'ernChanAveragedFromSub' num2str(subSel) '.jpg']);

%close all;
rawData=ern-crn;
splName='STUDY_headplot.spl';
%xx = readlocs('testFile.ced');
%timeArt=[8,2,7,6,5,1,4];
%x=xx(timeArt);

%x=chanLocs;
x=EEG.chanlocs;
headplot('setup', x, splName)
%close;
figure; 
headplot(rawData', splName)
%headplot(rawData, splName)
