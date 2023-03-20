#' Summarise document using LangChain and ChatGPT
#'
#' This function is a R wrapper of `chatgpt_chaindoc.py`, a python function aimed
#' to summarise large text documents using LangChain and ChatGPT.
#'
#' @param document_path The path of the txt document to summarise.
#' @param openaikey The OpenAI key token.
#' @param engine ChatGPT model (see \url{https://platform.openai.com/docs/models}).
#' @param temperature Level of randomness or "creativity" in the generated text (see \url{https://platform.openai.com/docs/api-reference/completions/create})
#'
#' @return A summarised text.
#' @export
#'

summarise_chatgpt_wrapper <- function(document_path, openaikey, engine, temperature) {
  chatgpt_chain_py <- reticulate::import("chatgpt_chaindoc")
  py_function <- chatgpt_chain_py$summarize_document
  result <- py_function(document_path, openaikey, engine, temperature)
  return(result)
}
