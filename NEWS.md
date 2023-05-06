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
