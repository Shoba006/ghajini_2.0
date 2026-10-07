from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional

from database import init_db, get_all_reminders
from face_recognition import recognize_person_from_image
from memory import retrieve_memories_for_question
from ai import generate_answer

app = FastAPI(title="Ghajini 2.0 Backend", description="Privacy-first AI Memory Prosthesis")

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup_event():
    init_db()
    print("[Backend] Database initialized and seeded successfully.")

@app.get("/health")
def health_check():
    return {"status": "ok"}

class ChatRequest(BaseModel):
    question: str

class ChatResponse(BaseModel):
    answer: str

@app.post("/chat", response_model=ChatResponse)
def chat_endpoint(request: ChatRequest):
    question = request.question.strip() if request.question else ""
    if not question:
        return ChatResponse(answer="Please enter a question.")

    # 1. Retrieve relevant memories using vector RAG
    retrieved_memories = retrieve_memories_for_question(question)

    # 2. Generate grounded answer using Ollama / memory context
    answer = generate_answer(question, retrieved_memories)

    return ChatResponse(answer=answer)

@app.post("/recognize")
async def recognize_endpoint(file: UploadFile = File(...)):
    if not file:
        raise HTTPException(status_code=400, detail="Image file is required")

    contents = await file.read()
    if not contents:
        return {"recognized": False, "message": "Person not recognized."}

    result = recognize_person_from_image(contents, filename=file.filename or "")
    return result

@app.get("/reminders")
def reminders_endpoint():
    reminders = get_all_reminders()
    return reminders
