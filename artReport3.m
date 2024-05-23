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

file_name = 'summaryArtifactRejectionsLstWithNoICA.txt';
%dataset_loadpath = 'C:\Users\glaze\Desktop\GorkaScripts\data\datasets\Processing\';
dataset_loadpath = 'C:\Users\John\Documents\MATLAB\soarData\';
%channelLocationFile = 'C:\Users\glaze\Documents\MatLabPrograms\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
channelLocationFile = 'C:\Users\John\Documents\MATLAB\eeglab2021.1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
erpset_savepath = 'C:\Users\John\Documents\MATLAB\soarData\erpLabs\';
load('erpHeader','ERPheader');
% Enter subject IDs here
subName = {'TRY100a_ERN', 'TRY101a_ERN','TRY102a_ERN'};
dirName = 'C:\Users\John\Documents\MATLAB\soarData\';
%subName='OSU-00001-04B-01-ERN.bdf';
%[sub] = subdir(dirName);

%metaData=struct2table(sub);
%fileList=metaData.name;
load('erplstNames.mat','erplstNames');
%load('erpernNames.mat','erpernNames');
%load('erpernsFiles.mat','erpernsFiles');
%fileList=erpernsFiles;


%ii=fileList(1);
subst='_erpset.erp';
outEx='_kukri_lst.mat';
%load EEGlab
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

for iSubject = 1:length(erplstNames)
fName=erplstNames{iSubject};
fOut=strcat(fName,outEx);
load(fOut);
ERP=EEG;

ERP.bindescr=ERPheader;
%ERP=erperns{iSubject};

index = strfind(fName, '\');

fName=fName((index(end)+1):end);

%     ii=fileList(iSubject);
% fName=ii{1};
% tf = endsWith(fName,subst);
% 
% if tf ~= (0)
%     try
    % load fully processed .erp erpset files
%     ERP = pop_loaderp('filename', [fName],...
%         'filepath', erpset_savepath);

    % if first subject, save the bin labels at header
    if iSubject == 1
        % save headers
        fid = fopen(file_name, 'a');
        header = 'subject, ';
        fprintf(fid, header);
        % populate accepted bin labels
        for bin = 1:ERP.nbin
            fprintf(fid, [char(ERP.bindescr(bin)) ' accepted, ']);
        end
        % populate rejected bin labels
        for bin = 1:ERP.nbin
            fprintf(fid, [char(ERP.bindescr(bin)) ' rejected, ']);
        end
        fclose(fid);
    end

    % open file to append
    fid = fopen(file_name, 'a');
    % save subject
    fprintf(fid, ['\n' fName ', ']);
    % save accepted trial count per bin
    for bin = 1:ERP.nbin
         fprintf(fid, [char(string(ERP.ntrials.accepted(bin))) ', ']);
    end
    % save rejected trial count per bin
    for bin = 1:ERP.nbin
         fprintf(fid, [char(string(ERP.ntrials.rejected(bin))) ', ']);
    end
    
    fclose(fid);    
%     catch
%     end
% end
end
%eeglab redraw