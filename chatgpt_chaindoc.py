from langchain.document_loaders import UnstructuredFileLoader
from langchain.chains.summarize import load_summarize_chain
from langchain import OpenAI
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain import PromptTemplate

def summarize_document(document_path, openaikey, engine, temperature):
    loader = UnstructuredFileLoader(document_path)
    document = loader.load()
    
    llm = OpenAI(
        openai_api_key=openaikey,
        temperature=temperature,
        max_tokens=1000,
        model_name=engine,
    )
    
    char_text_splitter = RecursiveCharacterTextSplitter(chunk_size=4000, chunk_overlap=200)
    docs = char_text_splitter.split_documents(document)

    prompt_template = """Write a concise summary of the following:
    
    {text}
    
    CONCISE SUMMARY IN ITALIAN:"""
    
    PROMPT = PromptTemplate(template=prompt_template, input_variables=["text"])
    
    refine_template = (
        "Your job is to produce a final summary\n"
        "We have provided an existing summary up to a certain point: {existing_answer}\n"
        "We have the opportunity to refine the existing summary"
        "(only if needed) with some more context below.\n"
        "------------\n"
        "{text}\n"
        "------------\n"
        "Given the new context, refine the original summary in Italian"
        "If the context isn't useful, return the original summary."
    )
    
    refine_prompt = PromptTemplate(
        input_variables=["existing_answer", "text"],
        template=refine_template,
    )
    
    model = load_summarize_chain(
        llm=llm,
        chain_type="refine",
        question_prompt=PROMPT,
        refine_prompt=refine_prompt,
        return_intermediate_steps=False
    )
    
    model({"input_documents": docs}, return_only_outputs=True)
    # summary = model.run(docs, return_only_outputs=True)
    #summary = chain({"input_documents": docs}, return_only_outputs=True)
    #return summary
