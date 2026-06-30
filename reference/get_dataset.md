# Get dataset metadata

A wrapper function of \[dataverse::get_dataset\].

## Usage

``` r
get_dataset(doi = NULL, dataverse_key = NULL)
```

## Arguments

- doi:

  The dataset DOI (eg. "10.7910/DVN/EXSAJ7").

- dataverse_key:

  Dataverse token.

## Value

A dataframe.

## Details

This function returns dataset' metadata information.

## Examples

``` r
if (FALSE) { # \dontrun{
get_dataset(doi = "10.7910/DVN/WMLQ3D", token = DATAVERSE_TOKEN)
} # }
```
