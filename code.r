import re

def split_paragraphs(input_text):
    pattern = re.compile(r'\n\d+\.\s[^\d.]+\.?\s*\n\n')

    # Find all matches of the pattern along with their indices
    matches = [(match.group(), match.start(), match.end()) for match in pattern.finditer(input_text)]

    paragraphs = []
    headings = []
    last_end = 0

    for match, start, end in matches:
        # Check conditions for invalid heading
        if (':' in input_text[last_end:start][-20:]) or ('(' in input_text[end:end+20]):
            # Add to the previous paragraph
            paragraphs[-1] += match
        else:
            # Valid heading, add to the lists
            headings.append(match)
            paragraphs.append(input_text[last_end:start].strip())

        last_end = end

    # Add the last paragraph
    paragraphs.append(input_text[last_end:].strip())

    # Combine paragraphs and headings
    result = [{'heading': heading, 'paragraph': paragraph} for heading, paragraph in zip(headings, paragraphs)]

    return result
