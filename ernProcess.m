function [totalErnAccuracy,corErnRts,incErnRts,meanEeg,meanErnEeg,meanCrnEeg,ernEpochCells,crnEpochCells,xPnts]=ernProcess(EEG,lern,preLength,winLength)


%--------------------------------------------------------------------------
 % ernProcess.m

 % Last updated: Feb 2024, John LaRocco
 
 % Ohio State University
 
 % Details: Extract features for ERN (flanker).
 
 % Input Variables: 
 % EEG: Struct of EEG from EEGLAB. 
 % lern: cell of inputs from Log files.
 % preLength: Pre-window baselining length in seconds.
 % winLength: Window length in seconds.

 % Output Variables: 

 % totalErnAccuracy: Accuracy from task. 
 % incErnRts/corErnRts: Vector array of (incorrect/correct) response times codes in ms.
 % meanEeg/meanErnEeg/meanCrnEeg: mean EEG from response times from (all/error/correct).
 % ernEpochCells/crnEpochCells: Cell structs from (error/correct) cells. '%
 % xPnts: vector to plot EEG with. 
%--------------------------------------------------------------------------


eventCodes=[3, 4];
[ernCorIndexPnts,corErnTimes,~,~,corErnRts]=soarEventFinder(EEG,eventCodes,lern);


eventCodes=[10, 11];
[ernIncIndexPnts,incErnTimes,~,~,incErnRts]=soarEventFinder(EEG,eventCodes,lern);

totalErnEvents=length(ernIncIndexPnts)+length(ernCorIndexPnts);
totalErnAccuracy=length(ernCorIndexPnts)./totalErnEvents;
eventCodes=[3, 4, 10, 11];


[epochCells,meanCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=ernEventEpochs(EEG,eventCodes,lern,preLength,winLength);

meanEeg=mean(meanCells);
xPnts=linspace(0,round(winLength*EEG.srate),length(meanEeg));


% error rates
eventCodes=[10, 11];
[ernEpochCells,ernMeanCells,~,~,~,~,~]=ernEventEpochs(EEG,eventCodes,lern,preLength,winLength);
meanErnEeg=mean(ernMeanCells);

eventCodes=[3, 4];
[crnEpochCells,crnMeanCells,~,~,~,~,~]=ernEventEpochs(EEG,eventCodes,lern,preLength,winLength);
meanCrnEeg=mean(crnMeanCells);

% only after stimuli appears
meanErnEeg=meanErnEeg(:,round(winLength*EEG.srate));
meanCrnEeg=meanCrnEeg(:,round(winLength*EEG.srate));


end