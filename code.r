def search_string_in_paragraphs(input_text, search_string):
    paragraphs = split_paragraphs(input_text)

    for paragraph in paragraphs:
        if search_string in paragraph['heading'] or search_string in paragraph['paragraph']:
            return paragraph

    return None