import re

def process_string(input_string):
    # Define a regular expression pattern to identify "\n" occurrences based on the given rules
    pattern = re.compile(r'(?<!\.)\n(?!\d|ARTICLE)')
    
    # Replace "\n" occurrences based on the defined pattern
    output_string = re.sub(pattern, ' ', input_string)
    
    return output_string

# Example usage:
input_string = "Your long input string here."
result = process_string(input_string)
print(result)
