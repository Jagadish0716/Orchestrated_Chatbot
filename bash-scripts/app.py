import streamlit as st
import os
import logging
import google.generativeai as genai
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

# ---------------------------
# Logging Configuration
# ---------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ---------------------------
# Streamlit Page Config
# ---------------------------
st.set_page_config(page_title="Jagadish ChatBot", layout="centered")
st.title("🧠 Jagadish ChatBot (Gemini)")

# ---------------------------
# Read API Key from Environment
# ---------------------------
api_key = os.getenv("GOOGLE_API_KEY")

if not api_key:
    st.error("GOOGLE_API_KEY not found. Update your Jenkins credentials.")
    st.stop()

# Configure the base Google SDK to list models
genai.configure(api_key=api_key)

# ---------------------------
# Helper: Fetch Available Models
# ---------------------------
@st.cache_data
def get_available_models():
    try:
        models = []
        for m in genai.list_models():
            # Filter for models that support 'generateContent' (Chat models)
            if 'generateContent' in m.supported_generation_methods:
                # remove 'models/' prefix for cleaner display if needed, 
                # but LangChain likes the full name or just the ID
                models.append(m.name.replace('models/', ''))
        return sorted(models)
    except Exception as e:
        logger.error(f"Could not fetch models: {e}")
        return ["gemini-1.5-flash", "gemini-1.5-pro"] # Fallback

# ---------------------------
# Sidebar Settings
# ---------------------------
st.sidebar.title("⚙️ Model Settings")

# Dynamic Model List
available_models = get_available_models()
model_name = st.sidebar.selectbox("Select Available Model", available_models)

temperature = st.sidebar.slider("Temperature", 0.0, 1.0, 0.7)
max_tokens = st.sidebar.slider("Max Tokens", 50, 2048, 500)

st.sidebar.divider()
st.sidebar.info(f"Connected to: **{model_name}**")

# ---------------------------
# Chat Logic
# ---------------------------
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful AI assistant named Jagadish ChatBot."),
    ("human", "{question}")
])

if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

def generate_response(question: str) -> str:
    try:
        chat_model = ChatGoogleGenerativeAI(
            model=model_name,
            google_api_key=api_key,
            temperature=temperature,
            max_output_tokens=max_tokens
        )
        chain = prompt | chat_model | StrOutputParser()
        return chain.invoke({"question": question})
    except Exception as e:
        return f"Error: {str(e)}"

# ---------------------------
# UI
# ---------------------------
user_input = st.chat_input("Ask a question...")

if user_input:
    st.session_state.chat_history.append(("User", user_input))
    answer = generate_response(user_input)
    st.session_state.chat_history.append(("Bot", answer))

for role, text in st.session_state.chat_history:
    with st.chat_message(role.lower()):
        st.write(text)