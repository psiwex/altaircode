import os
import csv
def search_files(folder_path):
    matching_files = []
    
    # Walk through the directory
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Check if the file ends with '.bdf' and contains 'npu'
            if file.endswith('.bdf') and 'npu' in file.lower():
                # Add the full path of the file to the list
                matching_files.append(os.path.join(root, file))
    
    return matching_files


def search_files_lst(folder_path):
    matching_files = []
    
    # Walk through the directory
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Check if the file ends with '.bdf' and contains 'lst'
            if file.endswith('.bdf') and 'lst' in file.lower():
                # Add the full path of the file to the list
                matching_files.append(os.path.join(root, file))
    
    return matching_files_lst


def search_files_ern(folder_path):
    matching_files = []
    
    # Walk through the directory
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Check if the file ends with '.bdf' and contains 'ern'
            if file.endswith('.bdf') and 'ern' in file.lower():
                # Add the full path of the file to the list
                matching_files.append(os.path.join(root, file))
    
    return matching_files_ern


# Specify the folder path you want to search
folder_to_search = 'C:\Users\John\Documents\MATLAB\soarCinci\'

# Call the function and get the list of matching files
result = search_files(folder_to_search)

resultLst = search_files_lst(folder_to_search)

resultErn = search_files_ern(folder_to_search)

# Print the list of matching files
if result:
    print("Files containing 'npu' and ending with '.bdf':")
    for file in result:
        print(file)
else:
    print("No matching files found for NPU.")


with open("outputNpu.csv", "w", newline='') as csvfile:
    # Create a CSV writer object
    writer = csv.writer(csvfile)

    # Write the fieldnames (column headers)
    writer.writerow(result)

with open("outputLst.csv", "w", newline='') as csvfile:
    # Create a CSV writer object
    writer = csv.writer(csvfile)

    # Write the fieldnames (column headers)
    writer.writerow(resultLst)

with open("outputErn.csv", "w", newline='') as csvfile:
    # Create a CSV writer object
    writer = csv.writer(csvfile)

    # Write the fieldnames (column headers)
    writer.writerow(resultErn)



