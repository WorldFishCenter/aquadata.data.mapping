% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shiny-functions.R
\name{read_file}
\alias{read_file}
\title{Read uploaded file}
\usage{
read_file(file = NULL)
}
\arguments{
\item{file}{The uploaded file.}
}
\value{
A text.
}
\description{
This function read uplaoded file from the user. It returns a object based
on the extension of the file. Allowed formats are docx, pdf, txt.
}
\examples{
\dontrun{
read_text("my_file.pdf")
}
}
