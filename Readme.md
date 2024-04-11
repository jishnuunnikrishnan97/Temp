result = sheet1_df.loc[sheet1_df['E'].isin(sheet2_df['A']), 'I'].sum()

result = sheet2_df.set_index('D').loc[B3, 'F'] if B3 in sheet2_df['D'].values else None