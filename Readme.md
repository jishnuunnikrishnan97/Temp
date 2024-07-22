```

import pandas as pd
import xml.etree.ElementTree as ET

def read_excel_xml(file_path):
    """
    Reads an Excel XML file and converts it into a pandas DataFrame.

    Parameters:
    - file_path (str): Path to the XML file.

    Returns:
    - pd.DataFrame: DataFrame containing the data from the XML file.
    """
    # Parse the XML content
    tree = ET.parse(file_path)
    root = tree.getroot()

    # Namespace dictionary to handle the default namespace
    namespaces = {'default': 'urn:schemas-microsoft-com:office:spreadsheet'}

    # Extract data
    data = []
    for row in root.findall('.//default:Row', namespaces):
        row_data = []
        for cell in row.findall('.//default:Data', namespaces):
            row_data.append(cell.text)
        data.append(row_data)

    # Create DataFrame
    df = pd.DataFrame(data)

    return df

# Example usage:
# df = read_excel_xml('your_file.xml')
# print(df)



```