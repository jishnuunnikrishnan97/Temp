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


from google.adk.agents import LlmAgent
from google.adk.agents.callback_context import CallbackContext
from google.adk.models import LlmResponse, LlmRequest
from google.adk.runners import Runner
from typing import Optional
from google.genai import types 
from google.adk.sessions import InMemorySessionService

GEMINI_2_FLASH="gemini-2.0-flash"

# --- Define the Callback Function ---
def simple_before_model_modifier(
    callback_context: CallbackContext, llm_request: LlmRequest
) -> Optional[LlmResponse]:
    """Inspects/modifies the LLM request or skips the call."""
    agent_name = callback_context.agent_name
    print(f"[Callback] Before model call for agent: {agent_name}")

    # Inspect the last user message in the request contents
    last_user_message = ""
    if llm_request.contents and llm_request.contents[-1].role == 'user':
         if llm_request.contents[-1].parts:
            last_user_message = llm_request.contents[-1].parts[0].text
    print(f"[Callback] Inspecting last user message: '{last_user_message}'")

    # --- Modification Example ---
    # Add a prefix to the system instruction
    original_instruction = llm_request.config.system_instruction or types.Content(role="system", parts=[])
    prefix = "[Modified by Callback] "
    # Ensure system_instruction is Content and parts list exists
    if not isinstance(original_instruction, types.Content):
         # Handle case where it might be a string (though config expects Content)
         original_instruction = types.Content(role="system", parts=[types.Part(text=str(original_instruction))])
    if not original_instruction.parts:
        original_instruction.parts.append(types.Part(text="")) # Add an empty part if none exist

    # Modify the text of the first part
    modified_text = prefix + (original_instruction.parts[0].text or "")
    original_instruction.parts[0].text = modified_text
    llm_request.config.system_instruction = original_instruction
    print(f"[Callback] Modified system instruction to: '{modified_text}'")

    # --- Skip Example ---
    # Check if the last user message contains "BLOCK"
    if "BLOCK" in last_user_message.upper():
        print("[Callback] 'BLOCK' keyword found. Skipping LLM call.")
        # Return an LlmResponse to skip the actual LLM call
        return LlmResponse(
            content=types.Content(
                role="model",
                parts=[types.Part(text="LLM call was blocked by before_model_callback.")],
            )
        )
    else:
        print("[Callback] Proceeding with LLM call.")
        # Return None to allow the (modified) request to go to the LLM
        return None


# Create LlmAgent and Assign Callback
my_llm_agent = LlmAgent(
        name="ModelCallbackAgent",
        model=GEMINI_2_FLASH,
        instruction="You are a helpful assistant.", # Base instruction
        description="An LLM agent demonstrating before_model_callback",
        before_model_callback=simple_before_model_modifier # Assign the function here
)

APP_NAME = "guardrail_app"
USER_ID = "user_1"
SESSION_ID = "session_001"

# Session and Runner
session_service = InMemorySessionService()
session = session_service.create_session(app_name=APP_NAME, user_id=USER_ID, session_id=SESSION_ID)
runner = Runner(agent=my_llm_agent, app_name=APP_NAME, session_service=session_service)


# Agent Interaction
def call_agent(query):
  content = types.Content(role='user', parts=[types.Part(text=query)])
  events = runner.run(user_id=USER_ID, session_id=SESSION_ID, new_message=content)

  for event in events:
      if event.is_final_response():
          final_response = event.content.parts[0].text
          print("Agent Response: ", final_response)

call_agent("callback example")

from google.adk.agents import Agent
from .sub_agents.contract.agent import contract_agent
from .sub_agents.invoices.agent import invoice_agent
from .sub_agents.leakage.agent import leakage_agent

from google.adk.agents import LlmAgent
from google.adk.agents.callback_context import CallbackContext
from google.adk.models import LlmResponse, LlmRequest
from typing import Optional


def my_before_model_logic(callback_context: CallbackContext, llm_request: LlmRequest) -> Optional[LlmResponse]:
    print(f"Callback running before model call for agent: {callback_context.agent_name}")
    #print("content_array:" , llm_request.contents) 
    data = llm_request.contents[-1].parts[1].inline_data.data 
    print("print_data: ", data)   
    return None

root_agent = Agent(
  name="contract_leakage_agent",
  model="gemini-1.5-flash", # Assuming "gemini-2.0-flash" was a typo, or use a valid model
  description="Interactive agent to ingest a contract, multiple invoices, then detect and explain financial leakages.",
  instruction="""

1. Greet the user and explain capabilities: can extract contract info, invoice info, detect leakages, answer follow-up questions.
2. Prompt user: "Please upload your contract document pdf or docx via the `document_uploader`." Store in `contract_document`.
3. Delegate to `contract_agent` to extract and display a **Contract Summary** in markdown.
4. Prompt user: "Please upload your invoice document pdf or docx."
4. Loop: ask "Upload an invoice? (yes/no)". On 'yes', prompt upload, store `invoice_document`, delegate to `invoice_agent` and append results to `invoices_data` and show an **Invoice Summary** in markdown; repeat. On 'no', break.
5. Once all invoices are collected, invoke `leakage_detector` subagent with `contract_data` and `invoices_data`, display detected leakages.
6. Finally, allow user to ask questions: for any follow-up, route to `leakage_detector` with context and answer.
""",
  sub_agents=[contract_agent, invoice_agent, leakage_agent],
  before_model_callback=my_before_model_logic
)





```
