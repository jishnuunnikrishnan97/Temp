import re

def split_paragraphs(input_text):
    pattern = re.compile(r'\n\d+\.\s[^\d.]+\.?\s*\n\n')
    paragraphs = pattern.split(input_text)
    headings = pattern.findall(input_text)

    # Remove empty strings from the list
    paragraphs = [para.strip() for para in paragraphs if para.strip()]

    result = []
    current_paragraph = {'heading': '', 'paragraph': ''}

    for heading, paragraph in zip(headings, paragraphs):
        # Check if the heading meets the specified conditions
        if ':' in heading[:20] or '(' in heading[-20:]:
            # Add heading and paragraph to the previous paragraph
            current_paragraph['heading'] += ' ' + heading
            current_paragraph['paragraph'] += ' ' + paragraph
        else:
            # Save the current paragraph and start a new one
            if current_paragraph['heading']:
                result.append(current_paragraph)
            current_paragraph = {'heading': heading, 'paragraph': paragraph}

    # Add the last paragraph to the result
    if current_paragraph['heading']:
        result.append(current_paragraph)

    return result
