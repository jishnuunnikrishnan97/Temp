```
## constants.py
import os
import dotenv

dotenv.load_dotenv()
 
AGENT_NAME = "brand_search_optimization"
DESCRIPTION = "A helpful assistant for brand search optimization."
PROJECT = os.getenv("GOOGLE_CLOUD_PROJECT", "EMPTY")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "global")
MODEL = os.getenv("MODEL", "gemini-2.0-flash-001")
DATASET_ID = os.getenv("DATASET_ID", "products_data_agent")
TABLE_ID = os.getenv("TABLE_ID", "shoe_items")
DISABLE_WEB_DRIVER = int(os.getenv("DISABLE_WEB_DRIVER", 0))
WHL_FILE_NAME = os.getenv("ADK_WHL_FILE", "")
STAGING_BUCKET = os.getenv("STAGING_BUCKET", "")

## bq_connector.py
from google.cloud import bigquery
from google.adk.tools import ToolContext

from ..shared_libraries import constants

# Initialize the BigQuery client outside the function
try:
    client = bigquery.Client()  # Initialize client once
except Exception as e:
    print(f"Error initializing BigQuery client: {e}")
    client = None  # Set client to None if initialization fails


def get_product_details_for_brand(tool_context: ToolContext):
    """
    Retrieves product details (title, description, attributes, and brand) from a BigQuery table for a tool_context.

    Args:
        tool_context (str): The tool_context to search for (using a LIKE '%brand%' query).

    Returns:
        str: A markdown table containing the product details, or an error message if BigQuery client initialization failed.
             The table includes columns for 'Title', 'Description', 'Attributes', and 'Brand'.
             Returns a maximum of 3 results.

    Example:
        >>> get_product_details_for_brand(tool_context)
        '| Title | Description | Attributes | Brand |\\n|---|---|---|---|\\n| Nike Air Max | Comfortable running shoes | Size: 10, Color: Blue | Nike\\n| Nike Sportswear T-Shirt | Cotton blend, short sleeve | Size: L, Color: Black | Nike\\n| Nike Pro Training Shorts | Moisture-wicking fabric | Size: M, Color: Gray | Nike\\n'
    """
    brand = tool_context.user_content.parts[0].text
    if client is None:  # Check if client initialization failed
        return "BigQuery client initialization failed. Cannot execute query."

    query = f"""
        SELECT
            Title,
            Description,
            Attributes,
            Brand
        FROM
            {constants.PROJECT}.{constants.DATASET_ID}.{constants.TABLE_ID}
        WHERE brand LIKE '%{brand}%'
        LIMIT 3
    """
    query_job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter("parameter1", "STRING", brand)
        ]
    )

    query_job = client.query(query, job_config=query_job_config)
    query_job = client.query(query)
    results = query_job.result()

    markdown_table = "| Title | Description | Attributes | Brand |\n"
    markdown_table += "|---|---|---|---|\n"

    for row in results:
        title = row.Title
        description = row.Description if row.Description else "N/A"
        attributes = row.Attributes if row.Attributes else "N/A"

        markdown_table += (
            f"| {title} | {description} | {attributes} | {brand}\n"
        )

    return markdown_table

## keyword_finding agent
from google.adk.agents.llm_agent import Agent

from ...shared_libraries import constants
from ...tools import bq_connector
from . import prompt

keyword_finding_agent = Agent(
    model=constants.MODEL,
    name="keyword_finding_agent",
    description="A helpful agent to find keywords",
    instruction=prompt.KEYWORD_FINDING_AGENT_PROMPT,
    tools=[
        bq_connector.get_product_details_for_brand,
    ],
)

## prompt
KEYWORD_FINDING_AGENT_PROMPT = """
Please follow these steps to accomplish the task at hand:
1. Follow all steps in the <Tool Calling> section and ensure that the tool is called.
2. Move to the <Keyword Grouping> section to group keywords
3. Rank keywords by following steps in <Keyword Ranking> section
4. Please adhere to <Key Constraints> when you attempt to find keywords
5. Relay the ranked keywords in markdown table
6. Transfer to root_agent

You are helpful keyword finding agent for a brand name.
Your primary function is to find keywords shoppers would type in when trying to find for the products from the brand user provided. 

<Tool Calling>
    - call `get_product_details_for_brand` tool to find product from a brand
    - Show the results from tool to the user in markdown format as is
    - Analyze the title, description, attributes of the product to find one keyword shoppers would type in when trying to find for the products from this brand
    - <Example>
        Input:
        |title|description|attribute|
        |Kids' Joggers|Comfortable and supportive running shoes for active kids. Breathable mesh upper keeps feet cool, while the durable outsole provides excellent traction.|Size: 10 Toddler, Color: Blue/Green|
        Output: running shoes, active shoes, kids shoes, sneakers
      </Example>
</Tool Calling>

<Keyword Grouping>
    1. Remove duplicate keywords
    2. Group the keywords with similar meaning
</Keyword Grouping>

<Keyword Ranking>
    1. If the keywords have the input brand name in it, rank them lower
    2. Rank generic keywords higher
</Keyword Ranking>
"""




## agent.py
from google.adk.agents.llm_agent import Agent

from .shared_libraries import constants

from .sub_agents.comparison.agent import comparison_root_agent
from .sub_agents.search_results.agent import search_results_agent
from .sub_agents.keyword_finding.agent import keyword_finding_agent

from . import prompt


root_agent = Agent(
    model=constants.MODEL,
    name=constants.AGENT_NAME,
    description=constants.DESCRIPTION,
    instruction=prompt.ROOT_PROMPT,
    sub_agents=[
        keyword_finding_agent,
        search_results_agent,
        comparison_root_agent,
    ],
)

ROOT_PROMPT = """
    You are helpful product data enrichment agent for e-commerce website.
    Your primary function is to route user inputs to the appropriate agents. You will not generate answers yourself.

    Please follow these steps to accomplish the task at hand:
    1. Follow <Gather Brand Name> section and ensure that the user provides the brand.
    2. Move to the <Steps> section and strictly follow all the steps one by one
    3. Please adhere to <Key Constraints> when you attempt to answer the user's query.

    <Gather Brand Name>
    1. Greet the user and request a brand name. This brand is a required input to move forward.
    2. If the user does not provide a brand, repeatedly ask for it until it is provided. Do not proceed until you have a brand name.
    3. Once brand name has been provided go on to the next step.
    </Gather Brand Name>

    <Steps>
    1. call `keyword_finding_agent` to get a list of keywords. Do not stop after this. Go to next step
    2. Transfer to main agent
    3. Then call `search_results_agent` for the top keyword and relay the response
        <Example>
        Input: |Keyword|Rank|
               |---|---|
               |Kids shoes|1|
               |Running shoes|2|
        output: call search_results_agent with "kids shoes"
        </Example>
    4. Transfer to main agent
    5. Then call `comparison_root_agent` to get a report. Relay the response from the comparison agent to the user.
    </Steps>

    <Key Constraints>
        - Your role is follow the Steps in <Steps> in the specified order.
        - Complete all the steps
    </Key Constraints>
"""

2025-05-21 14:23:22,468 - INFO - envs.py:47 - Loaded .env file for zip_file_manager at /home/user/Agents/zip_file_manager/.env
2025-05-21 14:23:22,528 - INFO - google_llm.py:83 - Sending out request, model: gemini-2.0-flash-001, backend: ml_dev, stream: False
2025-05-21 14:23:22,528 - INFO - google_llm.py:89 - 
LLM Request:
-----------------------------------------------------------
System Instruction:
 
You are a ZIP file manager. Whenever the user uploads a ZIP archive, route it to the `zip_extractor_agent`.
Otherwise, explain that you only handle ZIP uploads.
 
 
You are an agent. Your internal name is "zip_file_manager".
 
The description about you is "An agent to extract and list files inside uploaded ZIP archives."
 
 
You have a list of other agents to transfer to:
 
 
Agent name: zip_extractor_agent
Agent description: Agent to extract ZIP files and list their contents.
 
 
If you are the best to answer the question according to your description, you
can answer it.
 
If another agent is better for answering the question according to its
description, call `transfer_to_agent` function to transfer the
question to that agent. When transferring, do not generate any text other than
the function call.
 
-----------------------------------------------------------
Contents:
{"parts":[{"text":"Hi"}],"role":"user"}
-----------------------------------------------------------
Functions:
transfer_to_agent: {'agent_name': {'type': <Type.STRING: 'STRING'>}} -> None
-----------------------------------------------------------
 
2025-05-21 14:23:22,529 - INFO - models.py:6666 - AFC is enabled with max remote calls: 10.
2025-05-21 14:23:23,048 - INFO - _client.py:1740 - HTTP Request: POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-001:generateContent "HTTP/1.1 200 OK"
2025-05-21 14:23:23,049 - INFO - google_llm.py:145 - 
LLM Response:
-----------------------------------------------------------
Text:
I am designed to work with ZIP files. Please upload a ZIP archive for me to process, or I can transfer you to another agent.
 
-----------------------------------------------------------
Function calls:
 
-----------------------------------------------------------
Raw response:
{"candidates":[{"content":{"parts":[{"text":"I am designed to work with ZIP files. Please upload a ZIP archive for me to process, or I can transfer you to another agent.\n"}],"role":"model"},"finish_reason":"STOP","avg_logprobs":-0.10812436301132729}],"model_version":"gemini-2.0-flash-001","usage_metadata":{"candidates_token_count":29,"candidates_tokens_details":[{"modality":"TEXT","token_count":29}],"prompt_token_count":198,"prompt_tokens_details":[{"modality":"TEXT","token_count":198}],"total_token_count":227},"automatic_function_calling_history":[]}
-----------------------------------------------------------
 
2025-05-21 14:23:23,050 - INFO - fast_api.py:634 - Generated event in agent run streaming: {"content":{"parts":[{"text":"I am designed to work with ZIP files. Please upload a ZIP archive for me to process, or I can transfer you to another agent.\n"}],"role":"model"},"invocation_id":"e-3692ebd2-01af-4e8c-83ac-70318323c872","author":"zip_file_manager","actions":{"state_delta":{},"artifact_delta":{},"requested_auth_configs":{}},"id":"Gu4GugJN","timestamp":1747837402.474373}
INFO:     49.36.17.173:0 - "GET /apps/zip_file_manager/users/user/sessions/a479a9c4-a032-41b6-8d48-136013aa5c66 HTTP/1.1" 200 OK
INFO:     49.36.17.173:0 - "POST /run_sse HTTP/1.1" 200 OK
2025-05-21 14:24:13,758 - INFO - envs.py:47 - Loaded .env file for zip_file_manager at /home/user/Agents/zip_file_manager/.env
2025-05-21 14:24:13,797 - INFO - google_llm.py:83 - Sending out request, model: gemini-2.0-flash-001, backend: ml_dev, stream: False
2025-05-21 14:24:13,798 - INFO - google_llm.py:89 - 
LLM Request:
-----------------------------------------------------------
System Instruction:
 
You are a ZIP file manager. Whenever the user uploads a ZIP archive, route it to the `zip_extractor_agent`.
Otherwise, explain that you only handle ZIP uploads.
 
 
You are an agent. Your internal name is "zip_file_manager".
 
The description about you is "An agent to extract and list files inside uploaded ZIP archives."
 
 
You have a list of other agents to transfer to:
 
 
Agent name: zip_extractor_agent
Agent description: Agent to extract ZIP files and list their contents.
 
 
If you are the best to answer the question according to your description, you
can answer it.
 
If another agent is better for answering the question according to its
description, call `transfer_to_agent` function to transfer the
question to that agent. When transferring, do not generate any text other than
the function call.
 
-----------------------------------------------------------
Contents:
{"parts":[{"text":"Hi"}],"role":"user"}
{"parts":[{"text":"I am designed to work with ZIP files. Please upload a ZIP archive for me to process, or I can transfer you to another agent.\n"}],"role":"model"}
{"parts":[{"text":"Zip file"},{"inline_data":{"mime_type":"application/zip"}}],"role":"user"}
-----------------------------------------------------------
Functions:
transfer_to_agent: {'agent_name': {'type': <Type.STRING: 'STRING'>}} -> None
-----------------------------------------------------------
 
2025-05-21 14:24:13,798 - INFO - models.py:6666 - AFC is enabled with max remote calls: 10.
2025-05-21 14:24:13,918 - INFO - _client.py:1740 - HTTP Request: POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-001:generateContent "HTTP/1.1 400 Bad Request"
2025-05-21 14:24:13,924 - ERROR - fast_api.py:637 - Error in event_generator: 400 INVALID_ARGUMENT. {'error': {'code': 400, 'message': 'Unable to submit request because it has a mimeType parameter with value application/zip, which is not supported. Update the mimeType and try again. Learn more: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini', 'status': 'INVALID_ARGUMENT'}}
Traceback (most recent call last):
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/cli/fast_api.py", line 626, in event_generator
    async for event in runner.run_async(
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/runners.py", line 197, in run_async
    async for event in invocation_context.agent.run_async(invocation_context):
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/agents/base_agent.py", line 133, in run_async
    async for event in self._run_async_impl(ctx):
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/agents/llm_agent.py", line 246, in _run_async_impl
    async for event in self._llm_flow.run_async(ctx):
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/base_llm_flow.py", line 243, in run_async
    async for event in self._run_one_step_async(invocation_context):
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/base_llm_flow.py", line 268, in _run_one_step_async
    async for llm_response in self._call_llm_async(
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/base_llm_flow.py", line 483, in _call_llm_async
    async for llm_response in llm.generate_content_async(
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/models/google_llm.py", line 140, in generate_content_async
    response = await self.api_client.aio.models.generate_content(
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/genai/models.py", line 6672, in generate_content
    response = await self._generate_content(
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/genai/models.py", line 5674, in _generate_content
    response_dict = await self._api_client.async_request(
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/genai/_api_client.py", line 789, in async_request
    result = await self._async_request(http_request=http_request, stream=False)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/genai/_api_client.py", line 733, in _async_request
    await errors.APIError.raise_for_async_response(response)
  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/genai/errors.py", line 129, in raise_for_async_response
    raise ClientError(status_code, response_json, response)
google.genai.errors.ClientError: 400 INVALID_ARGUMENT. {'error': {'code': 400, 'message': 'Unable to submit request because it has a mimeType parameter with value application/zip, which is not supported. Update the mimeType and try again. Learn more: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini', 'status': 'INVALID_ARGUMENT'}}
```
