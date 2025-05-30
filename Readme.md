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


 
def save_text_to_pdf(text: str, pdf_path: str, fontsize: float = 12, margin: float = 50):
    # Create a new PDF
    pdf_doc = fitz.open()
 
    # A4 dimensions in points
    page_width, page_height = fitz.paper_size("a4")
 
    # Calculate wrapping & pagination metrics
    max_width = page_width - 2 * margin
    line_height = fontsize * 1.5
    # Approximate chars per line by assuming avg char width ≈ 0.5 * fontsize
    max_chars_per_line = max(40, int(max_width / (fontsize * 0.5)))
 
    # Break into wrapped lines
    all_lines = []
    for para in text.split('\n'):
        if not para.strip():
            all_lines.append("")      # preserve blank lines
        else:
            wrapped = textwrap.wrap(para, width=max_chars_per_line)
            all_lines.extend(wrapped)
 
    # Lines per page
    lines_per_page = int((page_height - 2 * margin) / line_height) or 1
 
    # Create pages and draw lines
    for start in range(0, len(all_lines), lines_per_page):
        page = pdf_doc.new_page(width=page_width, height=page_height)
        y = margin
        for line in all_lines[start : start + lines_per_page]:
            page.insert_text(
                (margin, y),
                line,
                fontsize=fontsize,
                fontname="helv"
            )
            y += line_height
 
    # Save & close
    pdf_doc.save(pdf_path)
    pdf_doc.close()
 


def pdf_file_to_bytes(path: str) -> bytes:
    with open(path, 'rb') as f:
        data = f.read()
    return data


data = convert_binary_str_to_docx(bin_str)
doc = Document(data)
save_text_to_pdf(docx_to_text(doc), 'test_wordbytestoPDF.pdf')

pdf_bytes = pdf_file_to_bytes('test_wordbytestoPDF.pdf')


```
