def extract_paragraph(text):
    pattern = re.compile(r'\n\d+\.\s*Term.*?(?=\n\d+\.\s*Term|\Z)', re.DOTALL)
    match = pattern.search(text)
    if match:
        return match.group(0)
    else:
        return None