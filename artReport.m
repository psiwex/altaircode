% Artifact Rejection: EEG Processing Summary Script for Gorka lab, James Glazer 3/7/23: glazerja1@gmail.com
%
% Description: Loads fully processed ERPsets and saves artifact rejection information for each subject
% 	Output file includes: accepted and rejected trial count for each bin in your Binlister
% 
% How to use:
% 	1. Run AFTER full preprocessing using EEG_Processing_Gorka.m
%   2. Enter the erpset folder location path for .erp files saved after completing preprocessing
%   3. Enter the file names for each subject erpset in the subName list
% 	4. Click Run.

clear all; close all; clc;

file_name = 'Summary_ArtifactRejectionErn52.txt';
%dataset_loadpath = 'C:\Users\glaze\Desktop\GorkaScripts\data\datasets\Processing\';
dataset_loadpath = 'C:\Users\John\Documents\MATLAB\soarData\';
%channelLocationFile = 'C:\Users\glaze\Documents\MatLabPrograms\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
erpset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\erpLabs\';

% Enter subject IDs here
subName = {'TRY100a_ERN', 'TRY101a_ERN','TRY102a_ERN'};
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
%subName='OSU-00001-04B-01-ERN.bdf';
%[sub] = subdir(dirName);

%metaData=struct2table(sub);
%fileList=metaData.name;

load('erpernsFiles.mat','erpernsFiles');
fileList=erpernsFiles;
load('erperns')
load('erpernNames.mat','erpernNames');
ii=fileList(1);
subst='_erpset.erp';
%load EEGlab
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
epochAccepted=[];
epochRejected=[];
for iSubject = 1:length(erperns)
ERP=erperns{iSubject};


                    y1=ERP.ntrials.accepted;
                    epochAccepted=[epochAccepted; y1];

                    y2=ERP.ntrials.rejected;
                    epochRejected=[epochRejected; y2];

end
%eeglab redraw