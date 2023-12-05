import pandas as pd

# Your 'Def' and 'update' dataframes

Def = {'Cust ID': [16283, 16284, 16285, 16286, 16287, 16288, 16289, 16290],
       'Cust Name': ['Tag', 'Tenet', 'Carp', 'Lager', 'Stout', 'Plum', 'Mead', 'Klark'],
       'AMT': ['Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan'],
       'LT': ['Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan'],
       'ST': ['Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan'],
       'SET': ['Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan', 'Nan']}

update = {'Cust ID': [16285, 16286, 16288],
          'Cust Name': ['Carp', 'Lager', 'Plum'],
          'AMT': [1000, 6789, 6728],
          'LT': ['TSK', 'Nan', 'OLS'],
          'ST': ['Nan', 'FLS', 'Nan'],
          'NET': ['HYUOL', 'HYUOL', 'HYUOL'],
          'MASK': ['YHLI', 'YHLI', 'YHLI']}

# Convert the dictionaries to dataframes
def_df = pd.DataFrame(Def)
update_df = pd.DataFrame(update)

# Merge based on 'Cust ID'
conc_df = pd.merge(def_df, update_df, on='Cust ID', how='left', suffixes=('_Def', '_Update'))

# Reorder the columns as per your 'conc' dictionary
column_order = ['Cust ID', 'Cust Name_Def', 'AMT_Update', 'LT_Update', 'ST_Update', 'SET_Def', 'NET_Update', 'MASK_Update']
conc_df = conc_df[column_order]

# Rename columns to match your 'conc' dictionary
conc_df.columns = ['Cust ID', 'Cust Name', 'AMT', 'LT', 'ST', 'SET', 'NET', 'MASK']

# Replace 'Nan' with NaN for consistency
conc_df.replace('Nan', pd.NA, inplace=True)

# Display the resulting dataframe
print(conc_df)
