sgl_index = df[df['Serial'] == 'SGL Account No.'].index[0]
df_cleaned = df[sgl_index+1:]
df_cleaned.reset_index(drop=True, inplace=True)