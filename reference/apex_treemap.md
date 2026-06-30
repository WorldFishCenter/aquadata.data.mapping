# Apexchart Treemap

Generate a treemap using the \`apexchart\` library (see
<https://dreamrs.github.io/apexcharter/index.html>)

## Usage

``` r
apex_treemap(series = NULL, colors = NULL, legend_size = 15)
```

## Arguments

- series:

  The series to plot. Generated from \`jsonify_metadata\`.

- colors:

  Treemap fill colors.

- legend_size:

  Legend font size.

## Value

An apexchart interactive plot.

## Examples

``` r
if (FALSE) { # \dontrun{
palette <- c(
  "#440154", "#30678D", "#35B778",
  "#FDE725", "#FCA35D", "#D32F2F", "#67001F"
)
colors <- palette %>% strtrim(width = 7)
dat <- jsonify_metadata()
apex_treemap(series = dat, colors = colors, legend_size = 15)
} # }
```
