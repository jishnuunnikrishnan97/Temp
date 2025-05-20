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


2025-05-20 16:14:50,143 - WARNING - types.py:4572 - Warning: there are non-text parts in the response: ['function_call'], returning concatenated text result from text parts. Check the full candidates.content.parts accessor to get the full model response.

Error in event_generator: table_id must be a fully-qualified ID in standard SQL format, e.g., "project.dataset.table_id", got None.sherif-440815.Finance_Contract_Agent.Employee_details

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

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/base_llm_flow.py", line 272, in _run_one_step_async

    async for event in self._postprocess_async(

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/base_llm_flow.py", line 342, in _postprocess_async

    async for event in self._postprocess_handle_function_calls_async(

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/base_llm_flow.py", line 417, in _postprocess_handle_function_calls_async

    if function_response_event := await functions.handle_function_calls_async(

                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/functions.py", line 165, in handle_function_calls_async

    function_response = await __call_tool_async(

                        ^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/functions.py", line 430, in __call_tool_async

    return await tool.run_async(args=args, tool_context=tool_context)

           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/tools/function_tool.py", line 82, in run_async

    return self.func(**args_to_call) or {}

           ^^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/bq_table_manager/tools/bq_table_toolkit.py", line 23, in create_or_replace_table

    table = bigquery.Table(table_id, schema=schema)

            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/cloud/bigquery/table.py", line 424, in __init__

    table_ref = _table_arg_to_table_ref(table_ref)

                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/cloud/bigquery/table.py", line 3762, in _table_arg_to_table_ref

    value = TableReference.from_string(value, default_project=default_project)

            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/cloud/bigquery/table.py", line 289, in from_string

    ) = _helpers._parse_3_part_id(

        ^^^^^^^^^^^^^^^^^^^^^^^^^^

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/cloud/bigquery/_helpers.py", line 1018, in _parse_3_part_id

    raise ValueError(

ValueError: table_id must be a fully-qualified ID in standard SQL format, e.g., "project.dataset.table_id", got None.sherif-440815.Finance_Contract_Agent.Employee_details

2025-05-20 16:14:50,152 - ERROR - __init__.py:157 - Failed to detach context

Traceback (most recent call last):

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/opentelemetry/trace/__init__.py", line 587, in use_span

    yield span

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/opentelemetry/sdk/trace/__init__.py", line 1105, in start_as_current_span

    yield span

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/opentelemetry/trace/__init__.py", line 452, in start_as_current_span

    yield span

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/google/adk/flows/llm_flows/base_llm_flow.py", line 500, in _call_llm_async

    yield llm_response

GeneratorExit
 
During handling of the above exception, another exception occurred:
 
Traceback (most recent call last):

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/opentelemetry/context/__init__.py", line 155, in detach

    _RUNTIME_CONTEXT.detach(token)

  File "/home/user/Agents/.venv/lib/python3.12/site-packages/opentelemetry/context/contextvars_context.py", line 53, in detach

    self._current_context.reset(token)

ValueError: <Token var=<ContextVar name='current_context' default={} at 0x7eb01fd59170> at 0x7eb004f2e140> was created in a different Context
 

```
