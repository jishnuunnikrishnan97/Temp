total_face_value_index = df[df['fresh'] == 'Total Face Value'].index[0]

df = df.iloc[:total_face_value_index]

result = df1[df1['col1'].isin(df2['col3'])]['col2'].sum()

result = sheet2_df.set_index('D').loc[B3, 'F'] if B3 in sheet2_df['D'].values else None