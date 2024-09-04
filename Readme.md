```
import re

def split_string(string):
  """Splits a string into a list of lists based on the specified criteria.

  Args:
    string: The input string.

  Returns:
    A list of lists containing the split substrings.
  """

  # Find all occurrences of '*Transaction*'
  matches = re.findall(r'\*Transaction\*.*?\*Transaction\*', string)

  # Extract the substrings between the matches, excluding the '*Transaction*' parts
  tsf = [match[13:-13] for match in matches]

  return tsf

# Example usage:
bare = "*Transaction*This is a sample transaction*Transaction*Another transaction*Transaction*"
tsf = split_string(bare)
print(tsf)



```