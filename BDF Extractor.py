import os
import shutil
import datetime

def create_extracted_folder():
    extracted_folder = os.path.join(os.getcwd(), 'extractedBDF')
    if not os.path.exists(extracted_folder):
        os.makedirs(extracted_folder)
        log_message(f"Created folder: {extracted_folder}")
    return extracted_folder
    # Create the 'extractedBDF' folder if it doesn't exist

def log_message(message):
    current_date = datetime.datetime.now().strftime("%Y-%m-%d")
    log_filename = f"ScriptLog-{current_date}.txt"
    log_filepath = os.path.join(os.getcwd(), log_filename)
    # Create log file

    with open(log_filepath, "a") as log_file:
        log_file.write(message + "\n")
        print(message)
        # Print current status in console

def search_files(root_dir, extracted_folder):
    wanted_extensions = ('ern.bdf', 'npu.bdf', 'lst.bdf')
    # Check if file contains 'ERN' or 'NPU' or 'LST' before '.bdf'

    for subdir, _, files in os.walk(root_dir):
        log_message(f"Searching in directory: {subdir}")
        for file in files:
            if file.lower().endswith(wanted_extensions):
                source_path = os.path.join(subdir, file)
                destination_path = os.path.join(extracted_folder, file)
                shutil.copy2(source_path, destination_path)
                log_message(f"Copied: {source_path} -> {destination_path}")
                # Copy file to the 'extractedBDF' folder

def main():
    root_dir = os.getcwd()
    extracted_folder = create_extracted_folder()
    search_files(root_dir, extracted_folder)
    log_message("Search and copy completed.")

if __name__ == "__main__":
    main()
# Created by Ian Zalcberg 10/24/24 for NeuroTech club at The Ohio State University for use on SOAR data
