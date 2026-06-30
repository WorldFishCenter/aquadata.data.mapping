# Download dataverse metadata

This function uses \[purrr::walk\] together with
\`get_organization_metadata\` to download Dataverse metadata from
several organizations. Data are then stored as csv files into
dataverse_raw folder.

## Usage

``` r
get_dataverse_metadata(log_threshold = logger::DEBUG)
```

## Arguments

- log_threshold:

  The (standard Apache logj4) log level used as a threshold for the
  logging infrastructure. See \[logger::log_levels\] for more details

## Value

Nothing, this function is used for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
get_dataverse_metadata()
} # }
```
