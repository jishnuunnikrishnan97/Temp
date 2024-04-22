
```

def find_files(directory):
    # Regex pattern to match filenames with specific keywords and file extensions
    pattern = re.compile(r'(deal\s*dump|omr).*\.(xlsx|csv|xlsb|xls)$', re.IGNORECASE)
    
    # List to store matching filenames
    matching_files = []
    
    # Loop through each file in the directory
    for filename in os.listdir(directory):
        # Check if the file matches the pattern
        if pattern.match(filename):
            matching_files.append(filename)
    
    return matching_files


```