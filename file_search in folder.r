def find_excel_file(folder_path):
    for file_name in os.listdir(folder_path):
        if file_name.startswith("Corporate Ratings Working") and file_name.endswith(".xlsx"):
            return os.path.join(folder_path, file_name)

    # Return None if no matching file is found
    return None
