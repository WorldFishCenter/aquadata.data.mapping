#' Summarise document using LangChain and ChatGPT
#'
#' This function is a R wrapper of `chatgpt_chaindoc.py`, a python script function
#' aimed to elaborate large text documents using LangChain and ChatGPT.
#' `chatgpt_chaindoc.py` uses the refine chain method to elaborate the text
#' (see \url{https://langchain.readthedocs.io/en/latest/modules/indexes/chain_examples/summarize.html#the-refine-chain} for details).
#'
#' @param document_path The path of the txt document to summarise.
#' @param openaikey The OpenAI key token.
#' @param engine ChatGPT model (see \url{https://platform.openai.com/docs/models}).
#' @param temperature Level of randomness or "creativity" in the generated text (see \url{https://platform.openai.com/docs/api-reference/completions/create}).
#' @param refine_text A text useful to refine the original prompt (see \url{https://langchain.readthedocs.io/en/latest/modules/indexes/chain_examples/summarize.html#the-refine-chain} for details).
#'
#' @return A summarised text.
#' @export
#' @examples
#' \dontrun{
#' output <-
#'   summarise_chatgpt_wrapper(
#'     document_path = "inst/docs_dataverse/5636634.txt",
#'     openaikey = OPENAI_KEY,
#'     engine = "gpt-3.5-turbo",
#'     temperature = 0.7,
#'     refine_text = pars$openai$refine_prompts$p1
#'   )
#' cat(output$output_text)
#' }
summarise_chatgpt_wrapper <- function(document_path, openaikey, engine, temperature, refine_text) {
  python_path <- system.file("/inst/python", package = "aquadata.data.mapping")
  chatgpt_chain_py <- reticulate::import_from_path(
    module = "chatgpt_chaindoc",
    path = python_path
  )
  py_function <- chatgpt_chain_py$summarize_document
  result <- py_function(
    document_path, openaikey, engine,
    temperature, refine_text
  )
  return(result)
}
