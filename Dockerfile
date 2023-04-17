FROM rocker/base:4.2.3

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
