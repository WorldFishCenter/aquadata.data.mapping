from langchain.document_loaders import UnstructuredFileLoader
from langchain.chains.summarize import load_summarize_chain
from langchain import OpenAI
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain import PromptTemplate

def summarize_document(document_path, openaikey, engine, temperature, refine_text):
    loader = UnstructuredFileLoader(document_path)
    document = loader.load()
    
    llm = OpenAI(
        openai_api_key=openaikey,
        temperature=temperature,
        max_tokens=1000,
        model_name=engine,
    )
    
    char_text_splitter = RecursiveCharacterTextSplitter(
      chunk_size=1000,
      chunk_overlap=200,
      length_function = len)
      
    docs = char_text_splitter.split_documents(document)

    prompt_template = """Write an extensive summary of the following:
    
    {text}
    
    FINAL STORY:"""
    
    PROMPT = PromptTemplate(template=prompt_template, input_variables=["text"])
    
    refine_template = (
        refine_text
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
    
    summary = model({"input_documents": docs}, return_only_outputs=True)
    return summary
