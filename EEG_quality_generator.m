classdef EEG_quality_generator
    % Class used to generate the quality statistics for ERN, LST and NPU
    % tests
    % Version 2: 2024-10-02 - should run on server
    % Written by:  Antoine Jean (jean.75@osu.edu / antoine.jean.2@ulaval.ca), 2024-09-11

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

        uniq_locations = {};
        n_entries = 0;
        subject_names = {};
        subject_locations = {};

        ern_qualities = [];
        lst_qualities = [];
        npu_qualities = [];    

        save_processed = true;
    end
    
    methods
        function obj = EEG_quality_generator(soarDataPath, savedDataPath, binlisters_path, channelLocationFile, save_processed)
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
            obj.save_processed = save_processed;

            % getting the subdirectory names - first level is the locations
            obj.uniq_locations = obj.getSubDirectories(soarDataPath);

            % get directory names - second level is the individuals 
            % Only add the subject if all files are present
            for i = 1:length(obj.uniq_locations)
                loc = char(obj.uniq_locations(i));
                individuals_at_location = obj.getSubDirectories([soarDataPath, loc]);
                for j = 1:length(individuals_at_location)
                    nam = char(individuals_at_location(j));
                    if obj.subject_contains_all_files(nam, loc)
                       % add the individual to the data
                       % saves the name and the location for future use
                       % doesn't save the path directly, it's reconstructed
                       % later from location + name
                       obj.subject_names{end + 1} = nam;
                       obj.subject_locations{end + 1} = loc;
                    end
                end
            end

            obj.n_entries = length(obj.subject_names);

            % initiating output arrays with 0s
            obj.ern_qualities = zeros(1, obj.n_entries);
            obj.lst_qualities = zeros(1, obj.n_entries);
            obj.npu_qualities = zeros(1, obj.n_entries);
        end
        
        function obj = calculate_all_quality_scores(obj)
            % runs preprocessing functions for all individuals 
            for i = 1:obj.n_entries
                [ern, lst, npu] = obj.calculate_quality_scores(i);
                obj.ern_qualities(i) = ern;
                obj.lst_qualities(i) = lst;
                obj.npu_qualities(i) = npu;  
            end
        end

        function [ern, lst, npu] = calculate_quality_scores(obj, subjectIndex)
            subjectName = char(obj.subject_names(subjectIndex));
            subjectlocation = char(obj.subject_locations(subjectIndex));
            % we know the files already exist if the subject is in the list
            [lstFileName, npuFileName, ernFileName] = obj.find_filenames(subjectName, subjectlocation);

            % run preprocessing functions once the files are found
            lst = -1;
            % Requires signal processing toolbox
            lst = obj.preproc(lstFileName, "LST", subjectName, subjectlocation);
            npu = obj.preproc(npuFileName, "NPU", subjectName, subjectlocation);
            ern = obj.preproc(ernFileName, "ERN", subjectName, subjectlocation); 

        end


        function [lstFileName, npuFileName, ernFileName] = find_filenames(obj, subjectName, subjectlocation)
            % find the filenames of the bdf files to read given the index
            filestem = [obj.raw_bdf_loadpath, '\', subjectlocation, '\', subjectName, '\'];
            
            % select path to look into, if Actiview doesn't exist we look
            % in the original directory
            path_containing_bdf_files = [filestem, 'Actiview\'];
            if exist(path_containing_bdf_files, 'dir') ~= 7
               path_containing_bdf_files = filestem;
            end
            
            % get the bdf file names
            [lstFileName, npuFileName, ernFileName] = obj.find_bdf_files_from_dir(path_containing_bdf_files);
        end

        function [lstFileName, npuFileName, ernFileName] = find_bdf_files_from_dir(obj, filename)
            % assuming the filename already exists
            lstFileName = obj.find_bdf_by_pattern(filename, "*LST.bdf");
            npuFileName = obj.find_bdf_by_pattern(filename, "*NPU.bdf");
            ernFileName = obj.find_bdf_by_pattern(filename, "*ERN.bdf");
        end



        function res = preproc(obj, filename, test_code, subjectName, subjectlocation)
            % checks if the file exists. If it does, calculate the
            % preprocessing function based on input string code, then saves
            % the data if save_processed == true. If file doesn't exist,
            % just returns -1, but this should not happen naturally
            % (version 2)
            if exist(filename, 'file') == 2
                if test_code == "LST"
                     [EEGe,~,~] = altairLstPreproc(filename, obj.binlisterPathLst, obj.channelLocationFile);
                elseif test_code == "NPU"
                     [EEGe,~,~] = altairNpuPreproc(filename,obj.raw_dataset_savepath,obj.ongoing_dataset_savepath,obj.erpset_savepath, obj.binlisterPathNpu, obj.channelLocationFile);
                elseif  test_code == "ERN"
                     [EEGe,~,~] = altairErnPreproc(filename,obj.raw_dataset_savepath,obj.ongoing_dataset_savepath,obj.erpset_savepath, obj.binlisterPathErn, obj.channelLocationFile);
                end
                [res] = altairAcceptedEpochs(EEGe);
                
                if obj.save_processed
                    processed_file = [obj.processed_dataset_savepath, char(subjectlocation), '_', ...
                        char(subjectName), '_' ,'Processed_', char(test_code)];
                    save(processed_file,'EEGe');
                end
            else 
                res = -1;
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


        function saveEEGtoCSV(obj)
            % saves quality percentages in csv along with id info for every
            % subject ('subject_name', 'subject_location', 'ern_quality', 'lst_quality', 'npu_quality')
            cellArray = cell(obj.n_entries, 4);
            for i = 1:obj.n_entries
                cellArray{i, 1} = obj.subject_names(i);
                cellArray{i, 2} = obj.subject_locations(i);
                cellArray{i, 3} = obj.ern_qualities(i);
                cellArray{i, 4} = obj.lst_qualities(i);
                cellArray{i, 5} = obj.npu_qualities(i);
            end
            T = cell2table(cellArray, 'VariableNames', {'subject_name', 'subject_location', 'ern_quality', 'lst_quality', 'npu_quality'});
            % Transpose so that all rows in table are records of one individual
            writetable(T,'eeg_quality_data.csv')
        end
        
        
        function res = subject_contains_all_files(obj, subjectName, subjectlocation)
            % returns a boolean if there are all 3 tests for subject name and location 
            [lstFileName, npuFileName, ernFileName] = obj.find_filenames(subjectName, subjectlocation);
            res = (~isempty(lstFileName) && ~isempty(npuFileName) && ~isempty(ernFileName));
        end

        function list_subjects(obj)
            for i = 1:obj.n_entries
                subjectName = char(obj.subject_names(i));
                subjectlocation = char(obj.subject_locations(i));
                is_valid = char(string(obj.subject_contains_all_files(subjectName, subjectlocation)));

                disp(['subject# ', char(num2str(i)), '|| Location: ', subjectlocation,  '|| Name: ', subjectName, ' || Contains all bdf results: ', is_valid]);
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

        function filename = find_bdf_by_pattern(dirname, pattern)
            % looks for all the files that correspond to a pattern in a
            % directory and return the first one (we could do the lowest
            % one alphabetically)
            filePattern = fullfile(dirname, pattern);
            files = dir(filePattern);
            if isempty(files)
                filename = '';
            else 
                filename = [char(dirname), char(files(1).name)];
            end  
        end

    end

end