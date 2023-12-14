def get_file_timestamp(file_path):
    timestamp = os.path.getmtime(file_path)
    # Convert timestamp to a human-readable format
    formatted_timestamp = datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    return formatted_timestamp