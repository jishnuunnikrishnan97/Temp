```

import os

path = 'c:\\input'

msi_sent_path, ipe_path, imex_path, non_payment_path = "", "", "", ""
checker_path, bnp_path, mt535_path, mt536_path, RDO_path = "", "", "", "", ""

file_list = os.listdir(path)

for file in file_list:
    file_lower = file.lower()
    
    if 'msi' in file_lower:
        msi_sent_path = os.path.join(path, file)
    elif 'ipe' in file_lower:
        ipe_path = os.path.join(path, file)
    elif 'imex' in file_lower:
        imex_path = os.path.join(path, file)
    elif 'payment' in file_lower:
        non_payment_path = os.path.join(path, file)
    elif 'checker' in file_lower:
        checker_path = os.path.join(path, file)
    elif 'bnp' in file_lower:
        bnp_path = os.path.join(path, file)
    elif '535' in file_lower:
        mt535_path = os.path.join(path, file)
    elif '536' in file_lower:
        mt536_path = os.path.join(path, file)
    elif 'receive deliver order' in file_lower:
        RDO_path = os.path.join(path, file)

missing_files = {
    "BNP file": bnp_path,
    "MT535 file": mt535_path,
    "MT536 file": mt536_path,
    "Receive Deliver Order List": RDO_path
}

for file_name, file_path in missing_files.items():
    if file_path == "":
        print(f"{file_name} missing. Some errors or discrepancies in the final output may occur!")




```