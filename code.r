def search_in_list(strings, input_text):
    result_list = []
    paragraphs = split_paragraphs(input_text)

    for search_term in strings:
        search_term_lower = search_term.lower()

        for entry in paragraphs:
            heading_lower = entry['heading'].lower()
            paragraph_lower = entry['paragraph'].lower()

            if search_term_lower in heading_lower or search_term_lower in paragraph_lower:
                result_list.append(entry['paragraph'])

    return result_list
