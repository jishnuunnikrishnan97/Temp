import re

text = """Your long text here"""

pattern = re.compile(r'\nVersion: August 29, 2006 Page.*?of 74\n', re.DOTALL)
modified_text = re.sub(pattern, '', text)

print(modified_text)
