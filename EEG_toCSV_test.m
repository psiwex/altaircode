clear;
clc;

% In order for the class to work properly as it is now, you should make sure to:
% 
% Point soarDataPath to the data directory that contains only the folders for
% the individuals we want to analyse (each individual folder in that directory should contain all 3 properly named bdf files 
% (each bdf file should be named: [subject_name]-[ERN|LST|NPU].bdf)). 
% We can ofc change the way the class reads the files if they're arranged differently in the supercomputer.
%
% savedDataPath can point to anywhere just all the preproc data will be
% sent somewhere in there
%
% binlisters_path should point to a directory that contain the 3 binlisters
% (you normally have off the github), with the proper names (i might have renamed ErnBinlister.txt)
% obj.binlisterPathErn = [binlisters_path, 'ErnBinlister.txt'];
% obj.binlisterPathLst = [binlisters_path, 'LstBinlister.txt'];
% obj.binlisterPathNpu = [binlisters_path, 'NpuBinlister.txt'];
%
% channelLocationFile just points to the channelLocationFile

% The way i've set it up on my machine is all these 4 folders are in the
% same level as the whole altaircode directory. Then I can just use the relative
% path to access them. In theory we could all set this up like
% this and not have to mess around with path variables too much. 
soarDataPath = '..\soarData\';
savedDataPath = '..\savedData';
binlisters_path = '..\binlisters\';
channelLocationFile = '..\EEGLAB_github_pull\eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';

% creates the path variables and reads the directory for subject names
EEGs = EEG_quality_generator(soarDataPath, savedDataPath, binlisters_path, channelLocationFile);

% list_subjects displays subject names in terminal, and whether or not for every subject
% it could find all 3 necessary bdf files. Output in terminal should look like this:
% subject# 1|| Name: OSU-TEST-01 || Contains all bdf results: true
% subject# 2|| Name: OSU-TEST-02 || Contains all bdf results: true
% subject# 3|| Name: OSU-TEST-03 || Contains all bdf results: true
EEGs.list_subjects();


% test_calculate_all_quality_scores simply fills the percentages with
% arbitrary floats to simulate the real thing
EEGs = EEGs.test_calculate_all_quality_scores();

% calculate_all_quality_scores is the real thing and calls all 3 preproc
% functions for all subjects. It takes me a good 5 minutes to run on my
% machine.
% EEGs = EEGs.calculate_all_quality_scores();

% This saves the data in a csv file in the same place as this .m file.
EEGs.saveEEGtoCSV();