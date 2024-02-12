function [xPnts]=npuProcess(EEG,lnpu,preLength,winLength)


%--------------------------------------------------------------------------
 % lstProcess.m

 % Last updated: Feb 2024, John LaRocco
 
 % Ohio State University
 
 % Details: Extract features for NPU (threats).
 
 % Input Variables: 
 % EEG: Struct of EEG from EEGLAB. 
 % lnpu: cell of inputs from Log files.
 % preLength: Pre-window baselining length in seconds.
 % winLength: Window length in seconds.

 % Output Variables: 
 % xPnts: vector to plot EEG with. 
%--------------------------------------------------------------------------
%winLength=1;


xPnts=linspace(0,1,round(EEG.srate*(winTotal+preTotal)));

%splName='STUDY_headplot.spl';
%xx = readlocs('Standard-10-10-Cap47.ced');
%headplot('setup', xx, splName)

%figure; 
%headplot(EEG.data, splName)



end