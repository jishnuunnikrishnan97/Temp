def preserve_newline_after_period(input_string):
    # Use regular expression to replace "\n" not after "."
    cleaned_string = re.sub('(?<!\.)\n(?! )', ' ', input_string)

    return cleaned_string