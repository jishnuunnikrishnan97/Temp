for key, value in input_dict.items():
        if not value:
            input_dict[key] = ['No provisions available']
        else:
            input_dict[key] = ['\n'.join(value)]

    # Add "Customer":[filename] as the first key-value pair
    input_dict = {"Customer": [filename], **input_dict}

    return input_dict