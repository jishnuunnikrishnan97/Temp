```
import pandas as pd

def filter_df_by_column_prefix(df, column_name, search_strings):
 

  if not isinstance(search_strings, list):
    search_strings = [search_strings]

  
  masks = [df[column_name].str.startswith(string) for string in search_strings]

 
  combined_mask = masks[0]
  for mask in masks[1:]:
    combined_mask |= mask

  
  filtered_df = df[combined_mask]
  return filtered_df



```