total_face_value_index = df[df['fresh'] == 'Total Face Value'].index[0]

df = df.iloc[:total_face_value_index]

filtered_sheet1_df = sheet1_df[sheet1_df['E'].isin(sheet2_df['A'])]
result = filtered_sheet1_df['I'].sum()

result = sheet2_df.set_index('D').loc[B3, 'F'] if B3 in sheet2_df['D'].values else None