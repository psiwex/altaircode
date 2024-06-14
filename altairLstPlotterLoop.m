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

load('lstArtRejection.mat','lstArtRep');
mainVec=lstArtRep(:,3);
rejThres=.8;
vals=find(mainVec>rejThres);

mainVals=mainVec(vals);

losGAvg=[];
winGAvg=[];

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
      if any(subSel == vals )
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

losGAvg(iss,:)=ern;
winGAvg(iss,:)=crn;
      end
end

ern=mean(losGAvg)*mean(maxs);
crn=mean(winGAvg)*mean(maxs);

figureHandle=figure;
xPnts=linspace(-(preLength),(winLength),length(ern));
plot(xPnts,(ern))
ylabel('Voltage (uV)')
ylim([-25 25])
xlabel('Time (ms)')
hold on;
plot(xPnts,(crn))
legend('Loss','Win')
hold off;
clear EEG;
%saveas(figureHandle,[fName 'lstChanGrat' num2str(chanSel) 'FromSub' num2str(subSel) '.jpg']);
load('OSU-00002-04B-01-LST.bdf_kukri_lst.mat')
%close all;
%x=EEG.data;
%figure; metaplottopo( EEG.data, 'plotfunc', 'erpimage', 'chanlocs', EEG.chanlocs);
%ern1=squeeze(x(:,:,1));
%ern2=squeeze(x(:,:,2));
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
