from langchain.chains import RetrievalQA
from PyPDF2 import PdfReader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import FAISS, Chroma
from langchain.chat_models import ChatOpenAI
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler


def qa_bot(document_path, openaikey, temperature, query_text):
    reader = PdfReader(document_path)

    raw_text = ''
    for i, page in enumerate(reader.pages):
        text = page.extract_text()
        if text:
            raw_text += text

    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=40,
        length_function=len
    )
    texts = text_splitter.split_text(raw_text)

    # Download embeddings from OpenAI
    embeddings = OpenAIEmbeddings(openai_api_key=openaikey)
    docsearch = FAISS.from_texts(texts, embeddings)
    
    retriever = docsearch.as_retriever(search_type="similarity", search_kwargs={"k":2})
    llm=ChatOpenAI(openai_api_key=openaikey,temperature = temperature)
    
    # create a chain to answer questions 
    qa = RetrievalQA.from_chain_type(
      llm=llm,
      chain_type="refine",
      retriever=retriever)
      
    query = query_text
    result = qa({"query": query})
    return result
