def search_strings_in_text(input_text, search_strings):
    result_dict = {}

    paragraphs = split_paragraphs(input_text)

    for search_str in search_strings:
        search_str_lower = search_str.lower()
        matching_paragraphs = []

        for entry in paragraphs:
            heading_lower = entry['heading'].lower()
            paragraph_lower = entry['paragraph'].lower()

            if search_str_lower in heading_lower or search_str_lower in paragraph_lower:
                matching_paragraphs.append(entry['paragraph'])

        result_dict[search_str] = matching_paragraphs

    return result_dict