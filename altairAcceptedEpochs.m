function [epochsAcceptedPercent] = altairAcceptedEpochs(EEG)
% Extract the EEG, based on Gorka's code
%
%  Parameters:
%     filename  EEGLAB EEG structure

%   Output:
%     EEG     EEGLAB EEG structure with the output
%
%   Written by:  John LaRocco, Feb 2016
%
% Assumes:  SOAR preprocessing base on Gorka for rough EEG.
y1=EEG.ntrials.accepted;
%epochAccepted=[epochAccepted; y1];
y2=EEG.ntrials.rejected;
%epochRejected=[epochRejected; y2];

epochsTotal = y1+y2;
epochsAcceptedPercent = y1/epochsTotal;
epochsAcceptedPercent=mean(epochsAcceptedPercent);
end