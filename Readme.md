
```
import pandas as pd

def lookup_amt_func(df1, df2, msg_ref_col='MsgRef', lookref_col='lookref', amt_col='amt', lookup_amt_col='lookup amt'):
  """
  Looks up values from a reference column in one DataFrame (df2) based on a matching column in another DataFrame (df1)
  and adds a new column with the corresponding values.

  Args:
      df1 (pandas.DataFrame): The DataFrame containing the column to look up values from (msg_ref_col).
      df2 (pandas.DataFrame): The reference DataFrame containing the lookup column (lookref_col) and the values to be looked up (amt_col).
      msg_ref_col (str, optional): The name of the column in df1 to look up values from. Defaults to 'MsgRef'.
      lookref_col (str, optional): The name of the column in df2 to use for lookup. Defaults to 'lookref'.
      amt_col (str, optional): The name of the column in df2 containing the values to be looked up. Defaults to 'amt'.
      lookup_amt_col (str, optional): The name of the new column in df1 to store the looked up values. Defaults to 'lookup amt'.

  Returns:
      pandas.DataFrame: The modified DataFrame (df1) with the new 'lookup amt' column.
  """

  # Create a dictionary from df2 for efficient lookups
  lookup_dict = df2.set_index(lookref_col)[amt_col].to_dict()

  # Add a new column 'lookup amt' to df1 using vectorized apply
  df1[lookup_amt_col] = df1[msg_ref_col].apply(lambda x: lookup_dict.get(x))

  return df1

```