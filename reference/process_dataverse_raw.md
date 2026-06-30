# Clean raw metadata

This function uses \`clean_dataverse_metadata\` to clean metadata raw
files into an unique and structured .rda file.

## Usage

``` r
process_dataverse_raw(log_threshold = logger::DEBUG)
```

## Arguments

- log_threshold:

  The (standard Apache logj4) log level used as a threshold for the
  logging infrastructure. See \[logger::log_levels\] for more details

## Value

Nothing, this function clean and store raw metadata into "data" folder.

## Examples

``` r
if (FALSE) { # \dontrun{
process_dataverse_raw()
} # }
```
