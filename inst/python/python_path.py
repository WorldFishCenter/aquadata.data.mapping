import os
import glob

# Get current working directory
cwd = os.getcwd()
print("Current working directory:", cwd)

# List all files in current directory
files = glob.glob("*")
print("Files in current directory:")
for file in files:
    print(file)
