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

fName2='OSU-00001-04B-01-ERN.bdf_kukri.mat';
load(fName2)
fName='OSU-00001-04B-01-ERN.bdf';
subst='.bdf';
outEx='_kukri_ern.mat';
logEx='.log';
ernSuf='ERN';
lstSuf='LST';
npuSuf='NPU';

dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
impName=strcat(subst,outEx);
[sub] = subdir(dirName);

metaData=struct2table(sub);
fileList=metaData.name;
ii=fileList(1);
for ij=1:length(fileList)
    ij/length(fileList);
    ii=fileList(ij);
    fName=ii{1}

    tf = endsWith(fName,impName);

    if (tf == true)
        load(fName)
        
            
            
         x0=strfind(fName,'.');
         prefixs=fName(1:(x0(1)-1));
         tf1 = endsWith(prefixs,ernSuf);
            if (tf1 == true)
                try
   

                    x=EEG.data;
                    x1=squeeze(x(1:chanLim,:,1));
                    x2=squeeze(x(1:chanLim,:,2));
                    x3=squeeze(x(1:chanLim,:,3));
                    x4=squeeze(x(1:chanLim,:,4));
                    ern1=.5*([ern1+x1]);
                    ern2=.5*([ern2+x2]);
                    ern3=.5*([ern3+x3]);
                    ern4=.5*([ern4+x4]);

                    y1=EEG.ntrials.accepted;
                    epochAccepted=[epochAccepted; y1];

                    y2=EEG.ntrials.rejected;
                    epochRejected=[epochRejected; y2];


                end
            end




    
end
%chanPercent=[chanPercent; chanPer];

save('ernM1.mat','ern1');
save('ernM2.mat','ern2');
save('ernM3.mat','ern3');
save('ernM4.mat','ern4');

save('epochAccepted.mat','epochAccepted');
save('epochRejected.mat','epochRejected');

end



finalMean=mean(ernAcc);




toc;