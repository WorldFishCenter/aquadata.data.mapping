FROM rocker/geospatial:4.2

# Install imports
RUN install2.r --error --skipinstalled \
    config \
    dataverse \
    digest \
    dplyr \
    janitor \
    logger \
    magrittr \
    officer \
    pdftools \
    readr \
    readxl \
    reticulate \
    rlang \
    stringr
