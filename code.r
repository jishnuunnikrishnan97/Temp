def split_paragraphs(text):
    pattern = re.compile(r'\n\d+\.\s+[A-Za-z\s]+\\n')
    paragraphs = pattern.split(text)
    paragraphs = [p.strip() for p in paragraphs if p.strip()]
    return paragraphs