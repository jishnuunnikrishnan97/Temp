```

#sub_agent
import json
import re
import pandas as pd
from tempfile import NamedTemporaryFile
 
from google.adk.agents import BaseAgent
from google.ai.generativelanguage import Content
 
 
class ExcelConverterAgent(BaseAgent):
    def __init__(self):
        super().__init__(
            name="ExcelConverter",
            description="Converts extracted tables into a multi-sheet Excel file"
        )
 
    async def run(self, context, input_data: Content):
        raw = input_data.parts[0].text
        tables = self._extract_tables(raw)
 
        if not tables:
            return Content(parts=[{"text": "No tables detected in the input."}])
 
        # Write each table to its own sheet in one Excel file
        with NamedTemporaryFile(delete=False, suffix=".xlsx") as tmp:
            with pd.ExcelWriter(tmp.name, engine="openpyxl") as writer:
                for idx, tbl in enumerate(tables, start=1):
                    df = pd.DataFrame(tbl["rows"], columns=tbl["columns"])
                    sheet = f"Table_{idx}"[:31]  # Excel max sheet name length
                    df.to_excel(writer, sheet_name=sheet, index=False)
            path = tmp.name
 
        # Read back bytes
        with open(path, "rb") as f:
            data = f.read()
 
        return Content(parts=[{
            "file_data": {
                "mime_type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "file_uri": path,
                "data": data
            }
        }])
 
    def _extract_tables(self, text: str):
        # 1) JSON-first
        t = text.strip()
        if t.startswith("{") or t.startswith("["):
            try:
                obj = json.loads(t)
                raw = obj.get("tables") if isinstance(obj, dict) else obj
                return [
                    {"columns": tbl["columns"], "rows": tbl["rows"]}
                    for tbl in raw
                    if "columns" in tbl and "rows" in tbl
                ]
            except json.JSONDecodeError:
                pass
 
        # 2) Markdown-style
        md = []
        for block in re.split(r"\n\s*\n", text):
            lines = block.strip().splitlines()
            if len(lines) >= 2 and lines[0].startswith("|") and re.match(r"^\|\s*[-:]+\s*(\|\s*[-:]+\s*)+\|?$", lines[1]):
                cols = [c.strip() for c in lines[0].strip("| ").split("|")]
                rows = []
                for row in lines[2:]:
                    cells = [c.strip() for c in row.strip("| ").split("|")]
                    cells += [""] * (len(cols) - len(cells))
                    rows.append(cells)
                md.append({"columns": cols, "rows": rows})
        if md:
            return md
 
        # 3) Plain-text blocks with pipes or tabs
        pts = []
        block = []
        for line in text.splitlines():
            if re.search(r"[│\|\t]", line):
                block.append(line)
            elif block:
                pts.append(self._parse_plain(block))
                block = []
        if block:
            pts.append(self._parse_plain(block))
        return pts
 
    def _parse_plain(self, lines):
        # Normalize │ → |
        norm = [re.sub(r"[│]", "|", ln) for ln in lines]
        rows = []
        for ln in norm:
            if "|" in ln:
                cells = [c.strip() for c in ln.strip("| ").split("|")]
            else:
                cells = [c.strip() for c in ln.split("\t")]
            rows.append(cells)
        # Pad
        mc = max(len(r) for r in rows)
        for r in rows:
            r += [""] * (mc - len(r))
        return {"columns": rows[0], "rows": rows[1:]}
 
 
def register_agents():
    return {"excel_converter": ExcelConverterAgent()}


error:
Traceback (most recent call last):
  File "C:\Agents\.venv\Lib\site-packages\google\adk\cli\fast_api.py", line 626, in event_generator
    async for event in runner.run_async(
    ...<8 lines>...
      yield f"data: {sse_event}\n\n"
  File "C:\Agents\.venv\Lib\site-packages\google\adk\runners.py", line 197, in run_async
    async for event in invocation_context.agent.run_async(invocation_context):
    ...<2 lines>...
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\agents\base_agent.py", line 141, in run_async
    async for event in self._run_async_impl(ctx):
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\agents\llm_agent.py", line 227, in _run_async_impl
    async for event in self._llm_flow.run_async(ctx):
      self.__maybe_save_output_to_state(event)
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\flows\llm_flows\base_llm_flow.py", line 231, in run_async
    async for event in self._run_one_step_async(invocation_context):
      last_event = event
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\flows\llm_flows\base_llm_flow.py", line 261, in _run_one_step_async
    async for event in self._postprocess_async(
    ...<2 lines>...
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\flows\llm_flows\base_llm_flow.py", line 329, in _postprocess_async
    async for event in self._postprocess_handle_function_calls_async(
    ...<2 lines>...
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\flows\llm_flows\base_llm_flow.py", line 419, in _postprocess_handle_function_calls_async
    async for event in agent_to_run.run_async(invocation_context):
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\agents\base_agent.py", line 141, in run_async
    async for event in self._run_async_impl(ctx):
      yield event
  File "C:\Agents\.venv\Lib\site-packages\google\adk\agents\base_agent.py", line 182, in _run_async_impl
    raise NotImplementedError(
        f'_run_async_impl for {type(self)} is not implemented.'
    )
NotImplementedError: _run_async_impl for <class 'PDF Data Extractor.subagents.excel_converter.agent.ExcelConverterAgent'> is not implemented.
2025-05-18 16:15:28,430 - ERROR - __init__.py:157 - Failed to detach context
Traceback (most recent call last):
  File "C:\Agents\.venv\Lib\site-packages\opentelemetry\trace\__init__.py", line 587, in use_span
    yield span
  File "C:\Agents\.venv\Lib\site-packages\opentelemetry\sdk\trace\__init__.py", line 1105, in start_as_current_span
    yield span
  File "C:\Agents\.venv\Lib\site-packages\opentelemetry\trace\__init__.py", line 452, in start_as_current_span
    yield span
  File "C:\Agents\.venv\Lib\site-packages\google\adk\flows\llm_flows\base_llm_flow.py", line 487, in _call_llm_async
    yield llm_response
GeneratorExit

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "C:\Agents\.venv\Lib\site-packages\opentelemetry\context\__init__.py", line 155, in detach
    _RUNTIME_CONTEXT.detach(token)
    ~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^
  File "C:\Agents\.venv\Lib\site-packages\opentelemetry\context\contextvars_context.py", line 53, in detach
    self._current_context.reset(token)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^
ValueError: <Token var=<ContextVar name='current_context' default={} at 0x00000245FBDDF1A0> at 0x000002459A78C980> was created in a different Context

```
