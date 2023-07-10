from langchain.chains import RetrievalQA
from PyPDF2 import PdfReader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import FAISS, Chroma
from langchain.llms import OpenAI

def qa_bot(document_path, openaikey, temperature, query_text):
    reader = PdfReader(document_path)

    raw_text = ''
    for i, page in enumerate(reader.pages):
        text = page.extract_text()
        if text:
            raw_text += text

    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=750,
        chunk_overlap=40,
        length_function=len
    )
    texts = text_splitter.split_text(raw_text)

    # Download embeddings from OpenAI
    embeddings = OpenAIEmbeddings(openai_api_key=openaikey)
    docsearch = FAISS.from_texts(texts, embeddings)
    
    retriever = docsearch.as_retriever(search_type="similarity", search_kwargs={"k":2})
    # create a chain to answer questions 
    qa = RetrievalQA.from_chain_type(
    llm=OpenAI(openai_api_key=openaikey, temperature = temperature), chain_type="refine", retriever=retriever)
    query = query_text
    result = qa({"query": query})
    return result
