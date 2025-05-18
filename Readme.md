```

2025-05-18 10:12:15,843 - INFO - envs.py:47 - Loaded .env file for PDF Data Extractor at C:\Agents\PDF Data Extractor\.env
2025-05-18 10:12:33,034 - ERROR - fast_api.py:637 - Error in event_generator: 1 validation error for LlmAgent
sub_agents.0
  Input should be a valid dictionary or instance of BaseAgent [type=model_type, input_value=<PDF Data Extractor.subag...t at 0x000002129EBC6120>, input_type=ExcelConverterAgent]
    For further information visit https://errors.pydantic.dev/2.11/v/model_type
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
    root_agent = Agent(
        name="PDF_Data_Extractor",
    ...<39 lines>...
        sub_agents=[excelConverter_agent]
        )
  File "C:\Agents\.venv\Lib\site-packages\pydantic\main.py", line 253, in __init__
    validated_self = self.__pydantic_validator__.validate_python(data, self_instance=self)
pydantic_core._pydantic_core.ValidationError: 1 validation error for LlmAgent
sub_agents.0
  Input should be a valid dictionary or instance of BaseAgent [type=model_type, input_value=<PDF Data Extractor.subag...t at 0x000002129EBC6120>, input_type=ExcelConverterAgent]
    For further information visit https://errors.pydantic.dev/2.11/v/model_type


```
