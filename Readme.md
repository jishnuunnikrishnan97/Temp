```
def read_text_file_contents(file_path):
  """Reads a text file and returns its contents as a single string.

  Args:
    file_path: The path to the text file.

  Returns:
    A string containing the contents of the text file.
  """

  try:
    with open(file_path, 'r') as file:
      contents = file.read()
      return contents
  except FileNotFoundError:
    print(f"File not found: {file_path}")
    return None

# Example usage:
file_path = "example.txt"  # Replace with the actual path to your file
content = read_text_file_contents(file_path)

if content:
  print(content)
else:
  print("Failed to read the file.")



```