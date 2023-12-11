def find_excel_file(folder_path, start_of_filename):
    try:
        # List all files in the specified folder
        files = os.listdir(folder_path)

        # Define the regex pattern for matching the filename
        pattern = re.compile(f"{re.escape(start_of_filename)}.*\.xlsx", re.IGNORECASE)

        # Filter the files based on the regex pattern
        matching_files = [file for file in files if pattern.match(file)]

        # If there are matching files, return the first one; otherwise, return None
        if matching_files:
            return os.path.join(folder_path, matching_files[0])
        else:
            return None

    except Exception as e:
        return f"Error: {str(e)}"
