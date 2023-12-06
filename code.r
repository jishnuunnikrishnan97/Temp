def remove_before_pattern(text, pattern):
    # Use re.DOTALL to match across multiple lines
    match = re.search(pattern, text, re.DOTALL)
    
    if match:
        # Extract everything after the matched pattern
        result = text[match.start():]
        return result
    else:
        return text