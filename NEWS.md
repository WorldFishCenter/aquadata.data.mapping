# aquadata.data.mapping 3.0.0

Integrated a shiny app with the following features:

- Display CGIAR metadata using a treemap from the `apexcharter` library
- Display an interactive table from the `reactable` library showing metadata
- Generate stories and summaries from text files using OpenAI api

# aquadata.data.mapping 2.0.0

- The repository gets automatically updated through github actions. The weekly pipeline
has the following steps:

1. Download raw metadata from Dataverse with `get_dataverse_metadata` and
`get_dataverse_metadata.py`
2. Clean and process raw Dataverse metadata in a single structured .rda file 
(with `process_dataverse_raw`)


# aquadata.data.mapping 1.0.0

- Integrated ChatGPT API with Langchain to produce stories from downloaded dataverse docs

# aquadata.data.mapping 0.1.0

* Added a `NEWS.md` file to track changes to the package.
