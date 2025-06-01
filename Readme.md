```
import io
import textwrap
from docx import Document
import fitz

class DocxToPdfConverter:
    @staticmethod
    def convert(docx_bytes: bytes, fontsize: float = 12, margin: float = 50) -> bytes:
        # Convert DOCX bytes to a Document object
        docx_stream = io.BytesIO(docx_bytes)
        doc = Document(docx_stream)
        
        # Extract text from DOCX paragraphs
        text = '\n\n'.join(para.text for para in doc.paragraphs)
        
        # Initialize PDF document
        pdf_doc = fitz.open()
        page_width, page_height = fitz.paper_size("a4")
        max_width = page_width - 2 * margin
        line_height = fontsize * 1.5
        
        # Calculate maximum characters per line based on average character width
        avg_char_width = fontsize * 0.5
        max_chars = int(max_width / avg_char_width)
        
        # Split text into lines
        lines = []
        for para in text.split('\n'):
            if para.strip() == "":
                lines.append("")
            else:
                wrapped_lines = textwrap.wrap(para, width=max_chars)
                lines.extend(wrapped_lines)
        
        # Calculate lines per page
        lines_per_page = int((page_height - 2 * margin) / line_height)
        
        # Create PDF pages with text
        for i in range(0, len(lines), lines_per_page):
            page = pdf_doc.new_page(width=page_width, height=page_height)
            y = margin
            for line in lines[i:i+lines_per_page]:
                if line:  # Skip empty lines
                    page.insert_text(
                        point=(margin, y),
                        text=line,
                        fontsize=fontsize,
                        fontname="helv",
                    )
                y += line_height
        
        # Return PDF as bytes
        pdf_bytes = pdf_doc.tobytes()
        pdf_doc.close()
        return pdf_bytes
 

```
