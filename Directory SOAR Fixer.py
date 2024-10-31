import os
import shutil
import re
import datetime

def rename_and_modify_files(directory, log_file_path):
    with open(log_file_path, 'a') as log_file:
        for folder_name in os.listdir(directory):
            folder_path = os.path.join(directory, folder_name)
            # Prepare log file and go through folders

            if os.path.isdir(folder_path) and folder_name.startswith('EEG'):
                parts = folder_name.split('_')
                if len(parts) != 3:
                    log_file.write(f"Skipping folder {folder_name} as it doesn't match the pattern\n")
                    continue

                xxxxx_xx = parts[1]  # xxxxx-xx part
                yy = parts[2].split('-')[-1]  # yy part
                # Check folder names

                new_folder_name = f"{yy}-{xxxxx_xx.replace('_', '-')}"
                new_folder_path = os.path.join(directory, new_folder_name)
                # Create the new folder name

                os.rename(folder_path, new_folder_path)
                log_file.write(f"Renamed {folder_name} to {new_folder_name}\n")
                # Rename the folder

                resources_path = os.path.join(new_folder_path, 'RESOURCES')
                if os.path.exists(resources_path):
                    for item in os.listdir(resources_path):
                        shutil.move(os.path.join(resources_path, item), new_folder_path)
                    os.rmdir(resources_path)
                    log_file.write(f"Moved contents of {resources_path} and removed the folder\n")
                eeg_folder_path = os.path.join(new_folder_path, 'EEG')
                if os.path.exists(eeg_folder_path):
                    for item in os.listdir(eeg_folder_path):
                        item_path = os.path.join(eeg_folder_path, item)
                        if os.path.isdir(item_path) and item.startswith('SOAR'):
                            new_item_path = os.path.join(eeg_folder_path, 'actiview')
                            os.rename(item_path, new_item_path)
                            log_file.write(f"Renamed folder {item} to actiview\n")
                # Fix folder mess and log

                    actiview_folder_path = os.path.join(eeg_folder_path, 'actiview')
                    if os.path.exists(actiview_folder_path):
                        for item in os.listdir(actiview_folder_path):
                            item_path = os.path.join(actiview_folder_path, item)
                            if item.endswith('.bdf'):
                                match = re.match(r'SOAR_15-\d+-\d+_(\w+)\.bdf', item)
                                if match:
                                    suffix = match.group(1)
                                    new_bdf_name = f"{new_folder_name} {suffix}.bdf"
                                    new_bdf_path = os.path.join(actiview_folder_path, new_bdf_name)
                                    os.rename(item_path, new_bdf_path)
                                    log_file.write(f"Renamed {item} to {new_bdf_name}\n")
                                else:
                                    log_file.write(f"Skipped renaming {item} as it did not match the .bdf pattern\n")
                                # BDF Process

                    for item in os.listdir(eeg_folder_path):
                        shutil.move(os.path.join(eeg_folder_path, item), new_folder_path)
                    os.rmdir(eeg_folder_path)
                    log_file.write(f"Moved contents of {eeg_folder_path} and removed the folder\n")
                    # EEG folder fixer (why did i only do this at the end, i have no idea, spaghetti code. You can personally blame this on me)

if __name__ == '__main__':
    script_directory = os.path.dirname(os.path.abspath(__file__))
    current_date = datetime.datetime.now().strftime('%Y-%m-%d')
    log_file_path = os.path.join(script_directory, f"{current_date} SOAR log.txt")
    rename_and_modify_files(script_directory, log_file_path)

    # Created by Ian Zalcberg and aided by ChatGPT 10/24/24 for NeuroTech club at The Ohio State University for use on SOAR data
