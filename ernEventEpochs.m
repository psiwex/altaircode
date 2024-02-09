function [epochCells,meanCells,indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=ernEventEpochs(EEG,eventCodes,lern,preLength,winLength)

%--------------------------------------------------------------------------
 % soarEventFinder.m

 % Last updated: Feb 2024, John LaRocco
 
 % Ohio State University
 
 % Details: Extract features for specific events.
 
 % Input Variables: 
 % EEG: Struct of EEG from EEGLAB. 
 % eventCodes: Array of event code target integers. (See below.) 
 % lern: cell of inputs from Log files. 
 % winLength: Window length in seconds.

 % Output Variables: 

 % epochCells: Cell array of specific epoched data.
 % meanCells: Matrix of average features/series
 % indexPnts: Each cell is features by observations.
 % sTimes: Each cell is EEG time series by observations, adjusted by sampling rate.
 % ernCodes: Vector array of event codes.
 % ernTimeStamps: Vector array of time stamps codes in ms. 
 % ernRts: Vector array of response times codes in ms.  
%--------------------------------------------------------------------------

epochCells=[];

winTotal=round(EEG.srate*(winLength));
preTotal=round(EEG.srate*(preLength));
[chans,samples]=size(EEG.data);
meanCells=zeros(chans,(preTotal+winTotal+1));
[indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=soarEventFinder(EEG,eventCodes,lern);

x=EEG.data;
indexFind=find(indexPnts<samples);
indexPnts=indexPnts(indexFind);

for iii=1:length(indexPnts)
eCap=indexPnts(iii)+winTotal;
try
x1=x(:,abs(indexPnts(iii)-preTotal):eCap);
xmeans=mean(x(:,abs(indexPnts(iii)-preTotal):indexPnts(iii))');
x1=x1-xmeans';
catch
x1=zeros(chans,preTotal+winTotal+1);
end
meanCells=meanCells+x1(:,1:(preTotal+winTotal+1));
epochCells{iii}=x1;
end

meanCells=meanCells./length(indexPnts);

end