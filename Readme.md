```

#root agent
from google.adk.agents import Agent
# from .subagents.excel_converter.agent import excelConverter_agent
from .subagents.excel_converter.agent import register_agents
sub_agents = register_agents()

root_agent = Agent(
    name="PDF_Data_Extractor",
    model="gemini-2.0-flash",
    description="Extract Data From PDF",
    sub_agents=list(sub_agents.value),
    instruction="""
        Purpose:
        You are a PDF Data Extractor Agent. Your sole responsibility is to extract data from PDF files based on user instructions. 
        You must never deviate from this purpose.
        ✅ Core Capabilities:
        Full PDF Extraction:
        When requested, extract and return the entire content of a PDF file in a readable format (text only).
        Selective Extraction:
        Extract specific sections of a PDF based on user queries, such as:
        Specific pages (e.g., "Extract page 3")
        Sections by heading or title (e.g., "Extract the 'Executive Summary'")
        Tables, bullet points, or paragraphs
        Keywords or phrases (e.g., "Find all mentions of 'revenue'")
        Structured Output:
        Present extracted content in a clean, structured format (e.g., plain text, JSON, or markdown) as appropriate.
        Multi-file Handling:
        If multiple PDFs are uploaded, handle each file independently and clearly label the output.
        ❌ Boundaries and Restrictions:
        Do NOT interpret or summarize the content. Only extract and return what is explicitly requested.
        Do NOT generate, modify, or create content outside of what is present in the PDF.
        Do NOT answer questions unrelated to PDF content extraction.
        Do NOT access external sources or perform web searches.
        Do NOT store or retain any user data or extracted content after the session ends.
        🧠 Behavior Rules:
        Always ask for clarification if the user’s request is ambiguous (e.g., unclear section names or vague keywords).
        If a requested section is not found, respond clearly:
        “The section titled ‘XYZ’ was not found in the document.”
        If the PDF is scanned or image-based, notify the user that text extraction may be limited unless OCR is enabled.
        Maintain data privacy and do not share extracted content with any third party.
        -When tables are detected:
        1. Extract raw table data with headers
        2. Structure data as JSON format:
        {
            "tables": [
                {
                    "columns": ["Header1", "Header2"],
                    "rows": [
                        ["Data1", "Data2"],
                        ["Data3", "Data4"]
                    ]
                }
            ]
        }
        3. Pass to excel_converter agent
        4. Return the generated Excel file
    
        """
    )



#Sub_agent
from google.adk.agents import BaseAgent
from google.ai.generativelanguage import Content
from google.ai.generativelanguage import Tool
import pandas as pd
import json
from tempfile import NamedTemporaryFile
import asyncio
 
class ExcelConverterTool(Tool):
    def __init__(self):
        super().__init__(
            name="excel_converter",
            description="Converts structured data tables to Excel format with multiple sheets"
        )
 
    async def _parse_tables(self, data: str):
        def _parse_tables(self, data: str):
        # Identify and extract tables from various formats
            tables = []
            
            # Try JSON parsing
            if data.strip().startswith("{"):
                try:
                    json_data = json.loads(data)
                    if isinstance(json_data, list):
                        tables = json_data
                    elif "tables" in json_data:
                        tables = json_data["tables"]
                    return tables
                except json.JSONDecodeError:
                    pass
    
            # Try markdown table parsing
            if "|-" in data or "|-" in data:
                tables = pd.read_csv(pd.compat.StringIO(data), sep="|", skipinitialspace=True).dropna(axis=1, how='all').to_dict(orient='records')
                return [tables]
    
            # Fallback to text parsing
            current_table = []
            for line in data.split('\n'):
                if any(char in line for char in ['│', '|', '\t']):
                    current_table.append(line)
                elif current_table:
                    tables.append(self._convert_text_table(current_table))
                    current_table = []
            if current_table:
                tables.append(self._convert_text_table(current_table))
                
            return tables
    
    async def execute(self, context, input_data: Content):
        # ADK-compliant execute method
        tables = await self._parse_tables(input_data.parts[0].text)
        
        if not tables:
            return Content(parts=[{"text": "No tables found in the input data"}])
 
        try:
            with NamedTemporaryFile(delete=False, suffix=".xlsx") as tmpfile:
                with pd.ExcelWriter(tmpfile.name, engine='openpyxl') as writer:
                    for i, table in enumerate(tables, 1):
                        df = pd.DataFrame(table[1:], columns=table[0])
                        df.to_excel(writer, sheet_name=f"Table_{i}", index=False)
                
                with open(tmpfile.name, "rb") as f:
                    excel_data = f.read()
                
                return Content(
                    parts=[{
                        "file_data": {
                            "mime_type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                            "file_uri": tmpfile.name,
                            "data": excel_data
                        }
                    }]
                )
        except Exception as e:
            return Content(parts=[{"text": f"Error generating Excel file: {str(e)}"}])
 
class ExcelConverterAgent(BaseAgent):
    def __init__(self):
        super().__init__(
            name="ExcelConverter",
            model="gemini-1.5-flash",
            description="Converts structured data to Excel format",
            tools=[ExcelConverterTool()]
        )
    
    async def run(self, context, input_data: Content):
        # Handle the conversion process
        return await self.tools[0].execute(context, input_data)
 
# ADK requires agent registration
def register_agents():
    return {
        "excel_converter": ExcelConverterAgent()
    }

error:
Traceback (most recent call last):
  File "C:\Agents\.venv\Lib\site-packages\google\adk\cli\fast_api.py", line 625, in event_generator
    runner = await _get_runner_async(req.app_name)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Agents\.venv\Lib\site-packages\google\adk\cli\fast_api.py", line 796, in _get_runner_async
    root_agent = await _get_root_agent_async(app_name)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Agents\.venv\Lib\site-packages\google\adk\cli\fast_api.py", line 773, in _get_root_agent_async
    agent_module = importlib.import_module(app_name)
  File "C:\Users\jishnuu\AppData\Roaming\uv\python\cpython-3.13.3-windows-x86_64-none\Lib\importlib\__init__.py", line 88, in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
           ~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<frozen importlib._bootstrap>", line 1387, in _gcd_import
  File "<frozen importlib._bootstrap>", line 1360, in _find_and_load
  File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 935, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 1026, in exec_module
  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed
  File "C:\Agents\PDF Data Extractor\__init__.py", line 1, in <module>
    from . import agent
  File "C:\Agents\PDF Data Extractor\agent.py", line 4, in <module>
    sub_agents = register_agents()
  File "C:\Agents\PDF Data Extractor\subagents\excel_converter\agent.py", line 96, in register_agents
    "excel_converter": ExcelConverterAgent()
                       ~~~~~~~~~~~~~~~~~~~^^
  File "C:\Agents\PDF Data Extractor\subagents\excel_converter\agent.py", line 86, in __init__
    tools=[ExcelConverterTool()]
           ~~~~~~~~~~~~~~~~~~^^
  File "C:\Agents\PDF Data Extractor\subagents\excel_converter\agent.py", line 11, in __init__
    super().__init__(
    ~~~~~~~~~~~~~~~~^
        name="excel_converter",
        ^^^^^^^^^^^^^^^^^^^^^^^
        description="Converts structured data tables to Excel format with multiple sheets"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    )
    ^
  File "C:\Agents\.venv\Lib\site-packages\proto\message.py", line 724, in __init__
    raise ValueError(
        "Unknown field for {}: {}".format(self.__class__.__name__, key)
    )
ValueError: Unknown field for ExcelConverterTool: name

```
