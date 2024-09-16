classdef EEG_quality_generator
    properties
        raw_bdf_loadpath = '';
        raw_dataset_savepath = '';
        ongoing_dataset_savepath = '';
        processed_dataset_savepath = '';
        erpset_savepath= '';
        raw_eventlist_savepath= '';
        processed_eventlist_savepath= '';

        binlisterPathErn = '';
        binlisterPathLst = '';
        binlisterPathNpu = '';
        channelLocationFile = '';

        n_entries = 0;
        subject_names = {};
        ern_qualities = [];
        lst_qualities = [];
        npu_qualities = [];     
    end
    
    methods
        function obj = EEG_quality_generator(soarDataPath, savedDataPath, binlisters_path, channelLocationFile)
            % When the class is created with a given soarDataPath (which should be a directory), it
            % automatically looks for folders in that directory. All folders found are assumed to be individuals (the name of the folder is the subject name) 
            % It will later look in those folder for specific entries:
            % [subject_name]-[ERN/LST/NPU].bdf
            % for each entry not found, the quality output is -1

            % saved data should be appropriately saved in savedDataPath

            % setting appropriate paths for passing into preproc functions
            obj.raw_bdf_loadpath = soarDataPath;
            obj.raw_dataset_savepath = savedDataPath;
            obj.ongoing_dataset_savepath = savedDataPath;
            obj.processed_dataset_savepath = strcat(savedDataPath,'\Completed\');
            obj.erpset_savepath= strcat(savedDataPath,'\erpLabs\');
            obj.raw_eventlist_savepath= strcat(savedDataPath,'\eventList\');
            obj.processed_eventlist_savepath= strcat(savedDataPath,'\procEventList\');
            obj.binlisterPathErn = [binlisters_path, 'ErnBinlister.txt'];
            obj.binlisterPathLst = [binlisters_path, 'LstBinlister.txt'];
            obj.binlisterPathNpu = [binlisters_path, 'NpuBinlister.txt'];
            % channelLocationFile: this path is found in your eeglab dipfit plugin folder: eeglab\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp
            obj.channelLocationFile = channelLocationFile;

            % getting the subdirectory names
            obj.subject_names = obj.getSubDirectories(soarDataPath);
            obj.n_entries = length(obj.subject_names);

            % initiating output arrays with 0s
            obj.ern_qualities = zeros(1, obj.n_entries);
            obj.lst_qualities = zeros(1, obj.n_entries);
            obj.npu_qualities = zeros(1, obj.n_entries);
        end
        
        function obj = calculate_all_quality_scores(obj)
            for i = 1:obj.n_entries
                [ern, lst, npu] = obj.calculate_quality_scores(obj.subject_names(i));
                obj.ern_qualities(i) = ern;
                obj.lst_qualities(i) = lst;
                obj.npu_qualities(i) = npu;  
            end
        end

        function obj = test_calculate_all_quality_scores(obj)
            % this is just to test out data saving stuff without having to
            % go through the very long and annoying preproc functions
            for i = 1:obj.n_entries
                obj.ern_qualities(i) = 0.1 * i;
                obj.lst_qualities(i) = 0.2 * i;
                obj.npu_qualities(i) = 0.3 * i;  
            end
        end

        function [ern, lst, npu] = calculate_quality_scores(obj, subjectName)
            subjectName = char(subjectName);
            filestem = [obj.raw_bdf_loadpath, subjectName, '\', subjectName];

            lstFileName = [filestem, '-LST.bdf'];
            lst = -1;
            % Requires signal processing toolbox
            % lst = obj.lstPreproc(lstFileName);

            npuFileName = [filestem, '-NPU.bdf'];
            npu = obj.npuPreproc(npuFileName);

            ernFileName = [filestem, '-ERN.bdf'];
            ern = obj.ernPreproc(ernFileName); 

        end


        function res = lstPreproc(obj, filename)
            if exist(filename, 'file') == 2
                [EEGe,~,~] = altairLstPreproc(filename, obj.binlisterPathLst, obj.channelLocationFile);
                [res] = altairAcceptedEpochs(EEGe);
            else 
                res = -1;
            end
        end

        function res = npuPreproc(obj, filename)
            if exist(filename, 'file') == 2
                [EEGe,~,~] = altairNpuPreproc(filename,obj.raw_dataset_savepath,obj.ongoing_dataset_savepath,obj.erpset_savepath, obj.binlisterPathNpu, obj.channelLocationFile);
                [res] = altairAcceptedEpochs(EEGe);
            else
                res = -1;
            end
        end

        % passes the processing function as an input to reuse code(works as long as all preprocessing functions have the same signature)
        function res = ernPreproc(obj, filename)
            if exist(filename, 'file') == 2
                [EEGe,~,~] = altairErnPreproc(filename,obj.raw_dataset_savepath,obj.ongoing_dataset_savepath,obj.erpset_savepath, obj.binlisterPathErn, obj.channelLocationFile);
                [res] = altairAcceptedEpochs(EEGe);
            else
                % if the file doesn't exist, the return value is -1 for now
                res = -1;
            end
        end

        function saveEEGtoCSV(obj)
            cellArray = cell(obj.n_entries, 4);
            for i = 1:obj.n_entries
                cellArray{i, 1} = obj.subject_names(i);
                cellArray{i, 2} = obj.ern_qualities(i);
                cellArray{i, 3} = obj.lst_qualities(i);
                cellArray{i, 4} = obj.npu_qualities(i);
            end
            T = cell2table(cellArray, 'VariableNames', {'subject_name', 'ern_quality', 'lst_quality', 'npu_quality'});
            % Transpose so that all rows in table are records of one individual
            writetable(T,'eeg_quality_data.csv')
        end
        
        % returns a boolean if the subject is correctly formatted in the
        % file system
        function res = subject_contains_all_files(obj, subjectName)
            subjectName = char(subjectName);
            filestem = [obj.raw_bdf_loadpath, subjectName, '\', subjectName];
            ernFileName = [filestem, '-ERN.bdf'];
            lstFileName = [filestem, '-LST.bdf'];
            npuFileName = [filestem, '-NPU.bdf'];
            
            res = exist(ernFileName, 'file') == 2 && ...
                exist(lstFileName, 'file') == 2 && ...
                exist(npuFileName, 'file') == 2;
        end

        function list_subjects(obj)
            for i = 1:obj.n_entries
                subName = char(obj.subject_names(i));
                is_valid = char(string(obj.subject_contains_all_files(subName)));
                disp(['subject# ', char(num2str(i)), '|| Name: ', subName, ' || Contains all bdf results: ', is_valid]);
            end
        end
    end

    methods (Static)
        function subDirs = getSubDirectories(dirPath)
                % Get a list of all files and folders in the given directory
                allItems = dir(dirPath);
                
                % Keep only the items that are directories and exclude '.' and '..'
                isSubDir = [allItems.isdir];  % Logical array for directories
                subDirs = {allItems(isSubDir).name};  % Extract names of directories              
                % Remove '.' and '..' from the list
                subDirs = subDirs(~ismember(subDirs, {'.', '..'}));

                
        end
    end
end