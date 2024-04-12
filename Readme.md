position_sum = position_df.groupby('ISIN')['Quantity'].sum().reset_index()

working_df = working_df.merge(position_sum, on='ISIN', how='left')

result = sheet2_df.set_index('D').loc[B3, 'F'] if B3 in sheet2_df['D'].values else None