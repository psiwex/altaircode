clear;
clc;
tic;

bnds=[.1,40];

ernAcc=[];
ernRtCor={};
ernRtInc={};

meanErnE=[];
meanCrnE=[];

meanWins=[];
meanLoss=[];


fName='OSU-00001-04B-01-ERN.bdf';
subst='.bdf';
outEx='.mat';
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
   
                    f2=strcat(prefixs,logEx);
                    f2 = strrep(f2,'Actiview','Behavioral');
                    ern = readtable(f2,'NumHeaderLines',5,ReadRowNames=true);
                    lern=table2cell(ern);
                    winLength=.5;
                    preLength=.5;
                    [totalErnAccuracy,corErnRts,incErnRts,meanEeg,meanErnEeg,meanCrnEeg,ernEpochCells,crnEpochCells,xPnts]=ernProcess(EEG,lern,preLength,winLength);
                    ernAcc=[ernAcc; totalErnAccuracy];
                    ernRtCor{ii}=corErnRts;
                    ernRtInc{ii}=incErnRts;
                    meanErnE=[meanErnE; meanErnEeg];
                    meanCrnE=[meanCrnE; meanCrnEeg];

                end
            end

        tf2 = endsWith(prefixs,lstSuf);
        if (tf2 == true)
            try
                f3=strcat(prefixs,logEx);
                f3 = strrep(f3,'Actiview','Behavioral');
                lst = readtable(f3,'NumHeaderLines',5,ReadRowNames=true);
                llst=table2cell(lst);
                winLength=1;
                [meanWinCells,meanLosCells,lstWin,lstLos,xPnts]=lstProcess(EEG,llst,winLength);
                meanWins=[meanWins; lstWin];
                meanLoss=[meanLoss; lstLos];
            end
        end

        tf3 = endsWith(prefixs,npuSuf);
        if (tf3 == true)
            try
                f4=strcat(prefixs,logEx);
                f4 = strrep(f4,'Actiview','Behavioral');
                npu = readtable(f4,'NumHeaderLines',7,ReadRowNames=true);
                lnpu=table2cell(npu);
                winLength=.5;
                preLength=.5;
                [xPnts]=ernProcess(EEG,lnpu,preLength,winLength);
            end
        end


    
end
%chanPercent=[chanPercent; chanPer];

save('ernAccSoar.mat','ernAcc');
save('ernRtCorSoar.mat','ernRtCor');
save('ernRtIncSoar.mat','ernRtInc');

save('meanErnESoar.mat','meanErnE');
save('meanCrnESoar.mat','meanCrnE');

save('meanLstWinsSoar.mat','meanWins');
save('meanLstLossSoar.mat','meanLoss');


end



finalMean=mean(ernAcc);




toc;