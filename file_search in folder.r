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





def find_sheet_in_excel(excel_file, start_of_sheet_name):
    try:
        # Read the Excel file into a dictionary of DataFrames (each DataFrame represents a sheet)
        excel_sheets = pd.read_excel(excel_file, sheet_name=None)

        # Define the regex pattern for matching the sheet name
        pattern = re.compile(f"^{re.escape(start_of_sheet_name)}", re.IGNORECASE)

        # Filter the sheet names based on the regex pattern
        matching_sheets = [sheet for sheet in excel_sheets.keys() if pattern.match(sheet)]

        # If there are matching sheets, return the first one; otherwise, print a message
        if matching_sheets:
            return matching_sheets[0]
        else:
            return "No sheet name found."

    except Exception as e:
        return f"Error: {str(e)}"
