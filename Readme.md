second_account_index = df[df['Serial'] == 'SGL Account No.'].index[1]

filtered_df = df.iloc[second_account_index:]

filtered_df.reset_index(drop=True, inplace=True)