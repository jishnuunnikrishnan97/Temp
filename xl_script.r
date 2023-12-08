import xml.etree.ElementTree as ET
import pandas as pd

def xml_to_excel(xml_file, excel_file):
    # Parse XML
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # Extract data from XML
    data = []
    for item in root.findall('.//your_element_path'):
        # Adjust 'your_element_path' to the actual path in your XML structure
        data.append([item.find('element1').text, item.find('element2').text, ...])

    # Create DataFrame
    columns = ['Column1', 'Column2', ...]  # Adjust column names
    df = pd.DataFrame(data, columns=columns)

    # Write to Excel
    df.to_excel(excel_file, index=False)

# Replace 'input.xml' and 'output.xlsx' with your file paths
xml_to_excel('input.xml', 'output.xlsx')
