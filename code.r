def split_paragraphs(input_text): 
    pattern = re.compile(r'\n\d+\.\s[^\d.]+\.?\s*\n\n')
    paragraphs = pattern.split(input_text)        
    headings = pattern.findall(input_text)

    paragraphs = [para.strip() for para in paragraphs if para.strip()]

    result = []
    prev_paragraph = ""

    for heading, paragraph in zip(headings, paragraphs):
        heading_text = heading.strip()

        # Check condition for heading not being a heading
        if ':' in heading_text[:20] or ('(' in heading_text[20:] and heading_text[20:].index('(') < 20):
            # Add heading and paragraph to the previous paragraph
            prev_paragraph += f"\n{heading}{paragraph}"
        else:
            # Add the heading and paragraph as a new entry
            result.append({'heading': heading, 'paragraph': paragraph})
            prev_paragraph = ""

    return result