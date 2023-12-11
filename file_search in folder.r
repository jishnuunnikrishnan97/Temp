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





def read_sheet_by_name_start(excel_file, start_of_sheet_name):
    try:
        # Read all sheet names from the Excel file
        all_sheet_names = pd.ExcelFile(excel_file).sheet_names

        # Define the regex pattern for matching the sheet name
        pattern = re.compile(f"{re.escape(start_of_sheet_name)}.*", re.IGNORECASE)

        # Find the first matching sheet name
        matching_sheet = next((sheet for sheet in all_sheet_names if pattern.match(sheet)), None)

        # If a matching sheet is found, create a dataframe; otherwise, print a message
        if matching_sheet:
            df = pd.read_excel(excel_file, sheet_name=matching_sheet)
            return df
        else:
            print("No matching sheet name found.")
            return None

    except Exception as e:
        return f"Error: {str(e)
