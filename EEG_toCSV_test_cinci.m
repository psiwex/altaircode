clear;
clc;

soarDataPath = '..\soarCinci\';
savedDataPath = '..\savedData';
binlisters_path = '..\soarEtl\currentSoar\';
channelLocationFile = '..\EEGLAB_github_pull\eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';

save_processed = true;

% creates the variables for saving data and reads the directory for subject
% names
EEGs = EEG_quality_generator(soarDataPath, savedDataPath, binlisters_path, channelLocationFile, save_processed);

% displays subject names in terminal, and wether or not for every subject
% it could find all 3 necessary bdf files

% it should look like this:
% subject# 1|| Name: OSU-TEST-01 || Contains all bdf results: true
% subject# 2|| Name: OSU-TEST-02 || Contains all bdf results: true
% subject# 3|| Name: OSU-TEST-03 || Contains all bdf results: true
EEGs.list_subjects();



% test_calculate_all_quality_scores simply fills the percentages with
% arbitrary floats to simulate the real thing
EEGs = EEGs.test_calculate_all_quality_scores();

% calculate_all_quality_scores is the real thing and call all 3 preproc
% functions for all subjects.
% To try it, just make sure list_subjects outputs a list of subject
% makes sense, and comment this line out: 
% EEGs = EEGs.calculate_all_quality_scores();

EEGs.saveEEGtoCSV();