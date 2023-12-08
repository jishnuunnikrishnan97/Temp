import os

def remove_extension(file_path):
    base_name = os.path.basename(file_path)
    file_name, _ = os.path.splitext(base_name)
    return file_name

# Example usage
file_path = '/path/to/your/file/example.txt'
result = remove_extension(file_path)
print(result)
