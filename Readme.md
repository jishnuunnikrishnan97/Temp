```
def search_ref_in_messages(message):
    for ref in df1['ref']:
        if ref.lower() in message.lower():  # case-insensitive search
            return ref
    return None


```