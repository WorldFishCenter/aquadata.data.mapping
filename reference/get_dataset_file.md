# Get file from dataverse dataset

A wrapper function of \[dataverse::get_dataframe_by_id\].

## Usage

``` r
get_dataset_file(dataset = NULL, file_id = NULL)
```

## Arguments

- dataset:

  A dataverse dataset returned from
  \[aquadata.data.mappind::get_dataset\].

- file_id:

  The dataverse file id.

## Value

An object based on the file extension. A dataframe in case of .csv or
.xlsx, a text for .pdf and .docx files.

## Details

This function returns a specific file associated to a dataverse dataset.
It returns an object based on the extension of the file. A dataframe in
case of .csv or .xlsx, a text for .pdf and .docx files.

## Examples

``` r
if (FALSE) { # \dontrun{
dataverse_dataset <- get_dataset(doi = "10.7910/DVN/WMLQ3D", token = DATAVERSE_TOKEN)
get_dataset_file(dataset = dataverse_dataset, id = 4570239)
} # }
```
