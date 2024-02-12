function [meanWinCells,meanLosCells,lstWin,lstLos,xPnts]=lstProcess(EEG,llst,winLength)


%--------------------------------------------------------------------------
 % lstProcess.m

 % Last updated: Feb 2024, John LaRocco
 
 % Ohio State University
 
 % Details: Extract features for LST (doors).
 
 % Input Variables: 
 % EEG: Struct of EEG from EEGLAB. 
 % lst: cell of inputs from Log files.
 % winLength: Window length in seconds.

 % Output Variables: 

 % totalErnAccuracy: Accuracy from task. 
 % incErnRts/corErnRts: Vector array of (incorrect/correct) response times codes in ms.
 % lstWin/lstLos: Mean EEG from response times from (all/error/correct).
 % ernEpochCells/crnEpochCells: Cell structs from (win/loss) cells. 
 % xPnts: vector to plot EEG with. 
%--------------------------------------------------------------------------
%winLength=1;
eventCodes=[6];
eventCodes=[11];
[~,meanWinCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=soarEventEpochs(EEG,eventCodes,llst,winLength);
lstWin=mean(meanWinCells);

eventCodes=[7];
eventCodes=[12];
[~,meanLosCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=soarEventEpochs(EEG,eventCodes,llst,winLength);
lstLos=mean(meanLosCells);
xPnts=linspace(0,1,length(lstWin));

%splName='STUDY_headplot.spl';
%xx = readlocs('Standard-10-10-Cap47.ced');
%headplot('setup', xx, splName)

%figure; 
%headplot(EEG.data, splName)



end