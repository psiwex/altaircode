clear;
clc;
tic;

bnds=[.1,30];
chanLim=48;
ernAcc=[];
ernRtCor={};
ernRtInc={};

ernCorCells={};
ernIncCells={};

epochAccepted=[];
epochRejected=[];



meanErnE=[];
meanCrnE=[];

meanWins=[];
meanLoss=[];
listWinCells={};
listLosCells={};
EEG.srate=256;
ern1=zeros(chanLim,round(EEG.srate*1.5));
ern2=zeros(chanLim,round(EEG.srate*1.5));
ern3=zeros(chanLim,round(EEG.srate*1.5));
ern4=zeros(chanLim,round(EEG.srate*1.5));
ern5=zeros(chanLim,round(EEG.srate*1.5));
ern6=zeros(chanLim,round(EEG.srate*1.5));

fName2='OSU-00001-04B-01-ERN.bdf_kukri.mat';
load(fName2)
fName='OSU-00001-04B-01-ERN.bdf';
subst='.bdf';
outEx='_kukri_npu.mat';
logEx='.log';
ernSuf='ERN';
lstSuf='LST';
npuSuf='NPU';

dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
impName=strcat(subst,outEx);
[sub] = subdir(dirName);
filzList={};

e1={};
e2={};
e3={};
e4={};
e5={};
e6={};


fileNums=[];

fCount=0;

metaData=struct2table(sub);
fileList=metaData.name;
ii=fileList(1);
for ij=1:length(fileList)
    ij/length(fileList);
    ii=fileList(ij);
    fName=ii{1};

    tf = endsWith(fName,impName);

    if (tf == true)
        load(fName);
        
            
            
         x0=strfind(fName,'.');
         prefixs=fName(1:(x0(1)-1));
         tf1 = endsWith(prefixs,ernSuf);
            if (tf1 == true)
                try
   
%tf1
ij
                    x=EEG.data;
                    x1=squeeze(x(1:chanLim,:,1));
                    x2=squeeze(x(1:chanLim,:,2));
                    x3=squeeze(x(1:chanLim,:,3));
                    x4=squeeze(x(1:chanLim,:,4));
                    x5=squeeze(x(1:chanLim,:,5));
                    x6=squeeze(x(1:chanLim,:,6));

                    ern1=.5*([ern1+x1]);
                    ern2=.5*([ern2+x2]);
                    ern3=.5*([ern3+x3]);
                    ern4=.5*([ern4+x4]);
                    ern5=.5*([ern5+x5]);
                    ern6=.5*([ern6+x6]);
                    fCount=fCount+1;
                    e1{fCount}=squeeze(x(:,:,1));
                    e2{fCount}=squeeze(x(:,:,2));
                    e3{fCount}=squeeze(x(:,:,3));
                    e4{fCount}=squeeze(x(:,:,4));
                    e5{fCount}=squeeze(x(:,:,5));
                    e6{fCount}=squeeze(x(:,:,6));

                    filzList{fCount}=fName;
                    fileNums=[fileNums ij];
                    y1=EEG.ntrials.accepted;
                    epochAccepted=[epochAccepted; y1];

                    y2=EEG.ntrials.rejected;
                    epochRejected=[epochRejected; y2];


                end
            end




    
end
%chanPercent=[chanPercent; chanPer];

save('npuM1.mat','ern1');
save('npuM2.mat','ern2');
save('npuM3.mat','ern3');
save('npuM4.mat','ern4');
save('npuM5.mat','ern5');
save('npuM6.mat','ern6');

save('npuEpochAccepted.mat','epochAccepted');
save('npuEpochRejected.mat','epochRejected');

save('npuN1.mat','e1');
save('npuN2.mat','e2');
save('npuN3.mat','e3');
save('npuN4.mat','e4');
save('npuN5.mat','e5');
save('npuN6.mat','e6');


save('npuFileNames.mat','filzList');
save('npuFileNums.mat','fileNums');

end



finalMean=mean(ernAcc);




toc;