```
from google.adk.agents import Agent
from .sub_agents.contract.agent import contract_agent
from .sub_agents.invoices.agent import invoice_agent
from .sub_agents.leakage.agent import leakage_agent

from google.adk.agents.callback_context import CallbackContext
from google.adk.models import LlmResponse, LlmRequest, types
from typing import Optional
from .converter import DocxToPdfConverter  # your converter class

def my_before_model_logic(
    callback_context: CallbackContext,
    llm_request: LlmRequest
) -> Optional[LlmResponse]:
    # Locate last user message
    if not llm_request.contents:
        return None

    last = llm_request.contents[-1]
    if last.role == "user" and last.parts and len(last.parts) > 1:
        file_part = last.parts[1]
        inline = getattr(file_part, "inline_data", None)
        if inline and inline.mime_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            # Convert DOCX → PDF
            try:
                pdf_bytes = DocxToPdfConverter.convert(inline.data)
            except Exception as e:
                return LlmResponse(
                    content=types.Content(
                        role="model",
                        parts=[types.Part(text=f"❌ Failed to convert DOCX → PDF: {e}")]
                    )
                )

            inline.data = pdf_bytes
            inline.mime_type = "application/pdf"
            # Optionally rename:
            # file_part.filename = file_part.filename.rsplit(".", 1)[0] + ".pdf"
            print(f"[Callback] Converted .docx to PDF for agent: {callback_context.agent_name}")

    return None


root_agent = Agent(
    name="contract_leakage_agent",
    model="gemini-1.5-flash",
    description="Interactive agent to ingest a contract, multiple invoices, then detect and explain financial leakages.",
    instruction="""
1. Greet the user and explain capabilities: can extract contract info, invoice info, detect leakages, answer follow-up questions.
2. Prompt user: "Please upload your contract document pdf or docx via the `document_uploader`." Store in `contract_document`.
3. Delegate to `contract_agent` to extract and display a **Contract Summary** in markdown.
4. Prompt user: "Please upload your invoice document pdf or docx."
5. Loop: ask "Upload an invoice? (yes/no)". On 'yes', prompt upload, store `invoice_document`, delegate to `invoice_agent` and append results to `invoices_data` and show an **Invoice Summary** in markdown; repeat. On 'no', break.
6. Once all invoices are collected, invoke `leakage_detector` subagent with `contract_data` and `invoices_data`, display detected leakages.
7. Finally, allow user to ask questions: for any follow-up, route to `leakage_detector` with context and answer.
""",
    sub_agents=[contract_agent, invoice_agent, leakage_agent],
    before_model_callback=my_before_model_logic
)

=============================================================================================================================================================================


from google.adk.agents import Agent
from .sub_agents.contract.agent import contract_agent
from .sub_agents.invoices.agent import invoice_agent
from .sub_agents.leakage.agent import leakage_agent
from google.adk.agents import LlmAgent
from google.adk.agents.callback_context import CallbackContext
from google.adk.models import LlmResponse, LlmRequest
from google.genai import types  # Required for Content/Part manipulation
from typing import Optional
import io
import textwrap
from docx import Document
import fitz  # PyMuPDF

class DocxToPdfConverter:
    @staticmethod
    def convert(docx_bytes: bytes, fontsize: float = 12, margin: float = 50) -> bytes:
        # (Same implementation as provided in your question)
        docx_stream = io.BytesIO(docx_bytes)
        doc = Document(docx_stream)
        text = '\n\n'.join(para.text for para in doc.paragraphs)
        
        pdf_doc = fitz.open()
        page_width, page_height = fitz.paper_size("a4")
        max_width = page_width - 2 * margin
        line_height = fontsize * 1.5
        avg_char_width = fontsize * 0.5
        max_chars = int(max_width / avg_char_width)
        
        lines = []
        for para in text.split('\n'):
            if para.strip() == "":
                lines.append("")
            else:
                wrapped_lines = textwrap.wrap(para, width=max_chars)
                lines.extend(wrapped_lines)
        
        lines_per_page = int((page_height - 2 * margin) / line_height)
        
        for i in range(0, len(lines), lines_per_page):
            page = pdf_doc.new_page(width=page_width, height=page_height)
            y = margin
            for line in lines[i:i+lines_per_page]:
                if line:
                    page.insert_text(
                        point=(margin, y),
                        text=line,
                        fontsize=fontsize,
                        fontname="helv",
                    )
                y += line_height
        
        pdf_bytes = pdf_doc.tobytes()
        pdf_doc.close()
        return pdf_bytes

def my_before_model_logic(callback_context: CallbackContext, llm_request: LlmRequest) -> Optional[LlmResponse]:
    print(f"Callback running before model call for agent: {callback_context.agent_name}")
    
    # Check if there's user content
    if not llm_request.contents or len(llm_request.contents) == 0:
        return None

    last_content = llm_request.contents[-1]
    
    # Process all parts of the last message
    for part in last_content.parts:
        # Check for DOCX file attachments
        if part.HasField('inline_data'):
            mime_type = part.inline_data.mime_type
            
            # Handle DOCX files
            if mime_type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
                print("Detected DOCX file - converting to PDF")
                try:
                    docx_bytes = part.inline_data.data
                    pdf_bytes = DocxToPdfConverter.convert(docx_bytes)
                    
                    # Update the request with converted PDF
                    part.inline_data.data = pdf_bytes
                    part.inline_data.mime_type = 'application/pdf'
                    print("Successfully converted DOCX to PDF")
                    
                except Exception as e:
                    print(f"Conversion error: {str(e)}")
                    # Return error response to user
                    return LlmResponse(
                        content=types.Content(
                            role="model",
                            parts=[types.Part(text=f"File processing error: {str(e)}")]
                        )
                    )
    
    return None  # Continue with modified request

root_agent = Agent(
  name="contract_leakage_agent",
  model="gemini-1.5-flash",
  description="Interactive agent to ingest a contract, multiple invoices, then detect and explain financial leakages.",
  instruction="""
1. Greet the user and explain capabilities...
2. Prompt user: "Please upload your contract document pdf or docx via the `document_uploader`..."
3. Delegate to `contract_agent`...
4. Loop for invoices...
5. Invoke `leakage_detector`...
6. Handle follow-up questions...
""",
  sub_agents=[contract_agent, invoice_agent, leakage_agent],
  before_model_callback=my_before_model_logic
)


```
