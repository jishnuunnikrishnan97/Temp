```

from langchain.llms import HuggingFacePipeline
from transformers import pipeline

# Use a smaller model to test
generator = pipeline("text-generation", model="distilgpt2")

# Wrap it with LangChain
llm = HuggingFacePipeline(pipeline=generator)

# Run the model
prompt = "What are the top skills for a data scientist?"
print(llm(prompt))


```
