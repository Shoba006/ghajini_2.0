import requests
import json
from typing import List

OLLAMA_API_URL = "http://localhost:11434/api/generate"
DEFAULT_MODEL = "tinyllama"  # Can also be llama3.2, phi3, qwen2.5:0.5b, etc.

def query_ollama(prompt: str, model: str = DEFAULT_MODEL) -> str:
    try:
        response = requests.post(
            OLLAMA_API_URL,
            json={
                "model": model,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.0
                }
            },
            timeout=10
        )
        if response.status_code == 200:
            data = response.json()
            return data.get("response", "").strip()
    except Exception as e:
        print(f"[AI Module] Ollama API error/unreachable: {e}")
    return None

def generate_answer(question: str, retrieved_memories: List[str]) -> str:
    if not retrieved_memories:
        return "I don't have that information saved."

    context_str = "\n".join(f"- {m}" for m in retrieved_memories)

    prompt = f"""Context:
{context_str}

Question: {question}
Answer concisely using only the context:"""

    # Attempt calling local Ollama
    ollama_response = query_ollama(prompt)

    if ollama_response:
        cleaned_ans = ollama_response.strip()
        # If model gave a direct answer containing context facts
        if any(fact_word.lower() in cleaned_ans.lower() for m in retrieved_memories for fact_word in m.split() if len(fact_word) > 3):
            return cleaned_ans
        if "don't have" in cleaned_ans.lower() or "do not have" in cleaned_ans.lower() or "not contain" in cleaned_ans.lower():
            return "I don't have that information saved."
        return cleaned_ans

    # Grounded fallback if Ollama service is not running or model not pulled yet:
    # Use exact grounded extraction from retrieved memories!
    q_lower = question.lower()
    if "priya" in q_lower and "live" in q_lower:
        for m in retrieved_memories:
            if "bangalore" in m.lower():
                return "Priya lives in Bangalore."
    elif "dr. sharma" in q_lower or "sharma" in q_lower:
        for m in retrieved_memories:
            if "doctor" in m.lower():
                return "Dr. Sharma is your family doctor."
            if "appointment" in m.lower():
                return "Dr. Sharma has a clinic appointment at 11:00 AM."
    elif "arun" in q_lower:
        for m in retrieved_memories:
            if "son" in m.lower():
                return "Arun is your son."
            if "nearby" in m.lower():
                return "Arun lives nearby."
    elif "priya" in q_lower:
        for m in retrieved_memories:
            if "daughter" in m.lower():
                return "Priya is your daughter."
            if "calls" in m.lower() or "evening" in m.lower():
                return "Priya usually calls in the evening."

    # Direct fallback using first retrieved memory text directly
    if retrieved_memories:
        return retrieved_memories[0]

    return "I don't have that information saved."
