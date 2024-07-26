```

import pandas as pd

def custom_formula(d_value, f_value):
    if f_value.startswith("ICAI"):
        # Extract the last 10 characters of d_value
        right_10 = d_value[-10:]
        # Extract the left 2 characters of right_10
        left_2 = right_10[:2]
        
        # Apply substitutions
        substitutions = {
            "EC": "J",
            "EL": "H",
            "EN": "L",
            "EP": "K",
            "IC": "D",
            "IG": "G",
            "IN": "B",
            "IU": "C",
            "LC": "A",
            "LT": "I",
            "PF": "M",
            "SG": "F",
            "TR": "E"
        }
        
        new_left_2 = substitutions.get(left_2, "#N/A")
        
        # Extract parts of the modified right_10
        mid_3 = right_10[2:3]
        mid_5 = right_10[4:5]
        right_5 = right_10[-5:]
        
        # Concatenate the results
        result = new_left_2 + mid_3 + mid_5 + right_5
        return result
    else:
        return "Old Ref"

# Create a sample DataFrame
df = pd.DataFrame({
    'D': ['example_data1ECxxxx', 'example_data2ELxxxx', 'example_data3ICxxxx'],
    'F': ['ICAI_somevalue1', 'ICAI_somevalue2', 'OTHER_value']
})

# Apply the custom formula
df['Result'] = df.apply(lambda row: custom_formula(row['D'], row['F']), axis=1)

print(df)



```