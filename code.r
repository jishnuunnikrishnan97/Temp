def search_strings(input_text, search_strings):
    result_dict = {}

    paragraphs = split_paragraphs(input_text)

    for search_term in search_strings:
        search_term_lower = search_term.lower()
        matching_paragraphs = []

        for entry in paragraphs:
            heading_lower = entry['heading'].lower()
            paragraph_lower = entry['paragraph'].lower()

            if search_term_lower in heading_lower or search_term_lower in paragraph_lower:
                matching_paragraphs.append(entry['paragraph'])

        result_dict[search_term] = matching_paragraphs

    return result_dict