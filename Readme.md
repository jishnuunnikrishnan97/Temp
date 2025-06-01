```
import io
import re
from docx import Document
import fitz
import textwrap
 
def convert_binary_str_to_docx(binary_data: bytes, return_io=True, save_path=None):
    if save_path:
        with open(save_path, 'wb') as f:
            f.write(binary_data)
 
    if return_io:
        return io.BytesIO(binary_data)
    
def docx_to_text(doc: Document):    
    return '\n\n'.join([para.text for para in doc.paragraphs])

 
def text_to_pdf_bytes(text: str, fontsize: float = 12, margin: float = 50) -> bytes:
    pdf_doc = fitz.open() 
    page_width, page_height = fitz.paper_size("a4")
    max_width = page_width - 2 * margin
    line_height = fontsize * 1.5
    max_chars = max(40, int(max_width / (fontsize * 0.5)))
    lines = []
    for para in text.split('\n'):
        if not para.strip():
            lines.append("") 
        else:
            lines += textwrap.wrap(para, width=max_chars)
    lines_per_page = max(1, int((page_height - 2 * margin) / line_height))
    for i in range(0, len(lines), lines_per_page):
        page = pdf_doc.new_page(width=page_width, height=page_height)
        y = margin
        for line in lines[i:i+lines_per_page]:
            page.insert_text((margin, y), line, fontsize=fontsize, fontname="helv")
            y += line_height
    pdf_bytes = pdf_doc.write()
    pdf_doc.close()
    return pdf_bytes
 

```
