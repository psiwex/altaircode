import os
import csv
import pathlib
import glob

def search_files(folder_path):
    matching_files = []
    
    # Walk through the directory
    for root, dirs, files in os.walk(folder_path):
        print(files)
        for file in files:
            # Check if the file ends with '.bdf' and contains 'npu'
            if file.endswith('.bdf') and 'npu' in file.lower():
                # Add the full path of the file to the list
                matching_files.append(os.path.join(root, file))
    
    return matching_files


def search_files_lst(folder_path):
    matching_files1 = []
    
    # Walk through the directory
    for root, dirs, files in os.walk(folder_path):
        print(files)
        for file in files:
            # Check if the file ends with '.bdf' and contains 'lst'
            if file.endswith('.bdf') and 'lst' in file.lower():
                # Add the full path of the file to the list
                matching_files1.append(os.path.join(root, file))
    
    return matching_files1


def search_files_ern(folder_path):
    matching_files2 = []
    
    # Walk through the directory
    for root, dirs, files in os.walk(folder_path):
        print(files)
        for file in files:
            # Check if the file ends with '.bdf' and contains 'ern'
            if file.endswith('.bdf') and 'ern' in file.lower():
                # Add the full path of the file to the list
                matching_files2.append(os.path.join(root, file))
    
    return matching_files2


def list_files(directory):
    for file in pathlib.Path(directory).rglob("*"):
        print(file)


def list_files2(directory):
    for file in glob.glob(directory + '/**/*', recursive=True):
        print(file)

# Example usage:


def list_files3(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            print(os.path.join(root, file))


# Specify the folder path you want to search
folder_to_search = 'C:/Users/John/MATLAB/Documents/MATLAB/soarCinci/.'
# Call the function and get the list of matching files
result = search_files(folder_to_search)

resultLst = search_files_lst(folder_to_search)

resultErn = search_files_ern(folder_to_search)

# Print the list of matching files
print(result)

print(resultLst)

print(resultErn)


saa=os.listdir()
#print(saa)

# Example usage:
#list_files(folder_to_search)

#list_files2(folder_to_search)
# Example usage:
#list_files3(folder_to_search)

#list_files3(folder_to_search)
#print(xx)

with open("outputCinci.csv", "w", newline='') as csvfile:
    # Create a CSV writer object
    writer = csv.writer(csvfile)

    # Write the fieldnames (column headers)
    writer.writerow(saa)



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




