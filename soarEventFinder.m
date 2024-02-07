function [indexPnts,sTimes,ernCodes,ernTimeStamps,ernRts]=soarEventFinder(EEG,eventCodes,lern)

%--------------------------------------------------------------------------
 % soarEventFinder.m

 % Last updated: Feb 2024, John LaRocco
 
 % Ohio State University
 
 % Details: Find sample index for separate events.
 
 % Input Variables: 
 % EEG: Struct of EEG from EEGLAB. 
 % eventCodes: Array of event code target integers. (See below.) 
 % lern: cell of inputs from Log files. 
 
 % Output Variables: 
 % indexPnts: Each cell is features by observations.
 % sTimes: Each cell is EEG time series by observations, adjusted by sampling rate.
 % ernCodes: Vector array of event codes.
 % ernTimeStamps: Vector array of time stamps codes in ms. 
 % ernRts: Vector array of response times codes in ms.  
%--------------------------------------------------------------------------

% event codes
% Flanker/ERN Task:
% ERROR TRIALS = 9 and 10
% CORRECT TRIALS = 3 and 4
% 
% LST/Doors Task:
% WIN TRIAL = 7
% LOSS TRIAL = 6

clc;
lern1=lern{1,5};
lern0=lern{1,4};
ernOffsetVal=abs(lern1-lern0);
ernTimeStamps=cell2mat(lern(:,4));
ernCodes=cell2mat(lern(:,3));
ernRts=cell2mat(lern(:,5));

[limLower, ~] = find(isnan(ernRts));
abLim=min(limLower)-1;
ernTimeStamps=ernTimeStamps(1:abLim);
ernCodes=ernCodes(1:abLim);
ernRts=ernRts(1:abLim);
truTimes=ernTimeStamps-ernOffsetVal;
sTimes=(truTimes/10000);
sTimes=round(sTimes*EEG.srate);

[roz, ~] = find(ernCodes==eventCodes);

indexPnts=sTimes(roz);
end

