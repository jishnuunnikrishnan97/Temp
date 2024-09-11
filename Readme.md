```
def clean_data(data):
    keyword = 'RESPONSE RECEIVED'
    cleaned_data = []

    for sublist in data:
        new_sublist = []
        for item in sublist:
            new_sublist.append(item)
            if keyword in item:
                break
        cleaned_data.append(new_sublist)

    return cleaned_data

```