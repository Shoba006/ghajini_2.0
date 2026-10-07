# Ghajini 2.0 — Privacy-First AI Memory Prosthesis

> **Hackathon Prototype**: A local, privacy-first AI memory companion prototype designed for assistive recall.
> **Disclaimer**: This prototype is intended purely for hackathon demonstration purposes and is **NOT** a clinically validated medical product or diagnosis tool.

---

## 1. Project Overview

**Ghajini 2.0** helps users with memory assistance through an end-to-end local privacy-first flow:
1. **Recognize Familiar Person**: Identify registered demo faces from camera capture.
2. **Show Identity & Relationship**: Display name and relationship clearly (e.g. "Priya — Daughter").
3. **Ask Personal Memory**: Ask natural-language questions about stored personal memories.
4. **Vector Memory RAG Retrieval**: Retrieve exact stored facts using sentence-transformers + FAISS.
5. **Grounded Local LLM Answer**: Generate short, strict answers using local Ollama without hallucination.
6. **Predefined Reminder**: Display and schedule local notifications for important events (e.g., Doctor appointment at 11:00 AM).

---

## 2. System Architecture

```
Flutter Mobile / Desktop App
         ↓ (HTTP / JSON)
  FastAPI Backend (localhost:8000)
         ↓
 ├── SQLite Database (People, Memories, Reminders)
 ├── InsightFace + OpenCV (Face Recognition)
 ├── sentence-transformers (Text Embeddings)
 ├── FAISS (Vector Index Retrieval)
 └── Ollama (Local LLM - tinyllama)
```

---

## 3. Project Structure

```
ai-memory-prosthesis/
├── frontend/                     # Flutter UI Application
│   ├── lib/
│   │   ├── main.dart             # Entry point & theme setup
│   │   ├── screens/
│   │   │   ├── home_screen.dart        # Screen 1: Home & Reminder
│   │   │   ├── recognition_screen.dart # Screen 2: Face Recognition
│   │   │   └── chat_screen.dart       # Screen 3: Ask Memory RAG
│   │   └── services/
│   │       ├── api_service.dart        # FastAPI backend integration
│   │       └── notification_service.dart# Flutter local notifications
│   ├── pubspec.yaml
│   └── test/
│       └── widget_test.dart
│
├── backend/                      # Python FastAPI Backend
│   ├── main.py                   # REST API routes (/health, /recognize, /chat, /reminders)
│   ├── database.py               # SQLite schema & auto-seeding
│   ├── face_recognition.py       # InsightFace + OpenCV recognition
│   ├── memory.py                 # sentence-transformers + FAISS RAG
│   ├── ai.py                     # Ollama Local LLM integration
│   ├── test_backend.py           # Backend unit tests
│   └── requirements.txt          # Python dependencies
│
├── data/                         # Local Data Store
│   └── people/                   # Demo enrolled face photos
│       ├── priya/
│       ├── arun/
│       └── doctor_sharma/
│
└── README.md                     # Documentation & setup guide
```

---

## 4. Prerequisites

- **Flutter SDK**: 3.x+
- **Python**: 3.10+
- **Ollama**: 0.3.0+
- **OS**: macOS / Linux / Windows

---

## 5. Quick Start Guide

### Step 1: Start Ollama Local LLM
```bash
# Start Ollama service
ollama serve

# Pull small local model (in another terminal tab)
ollama pull tinyllama
```

### Step 2: Set Up & Run FastAPI Backend
```bash
cd backend

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run test suite to verify backend & database seeding
python test_backend.py

# Start FastAPI server on port 8000
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

The backend automatically creates and seeds `data/memory.db` with demo people, memories, and reminders on startup!

### Step 3: Run Flutter Frontend
```bash
cd frontend

# Fetch dependencies
flutter pub get

# Run tests
flutter test

# Launch App (macOS, iOS, Android, or Web)
flutter run
```

---

## 6. Demo Face Data Setup

To enroll demo faces for InsightFace face recognition:

Place 2 photo samples per person in `data/people/`:
- `data/people/priya/image1.jpg` & `image2.jpg`
- `data/people/arun/image1.jpg` & `image2.jpg`
- `data/people/doctor_sharma/image1.jpg` & `image2.jpg`

The recognition engine loads embeddings automatically on backend startup.

---

## 7. API Reference Contracts

### `GET /health`
- **Response**: `{"status": "ok"}`

### `POST /recognize`
- **Payload**: Multipart form-data with `file` (Image upload)
- **Success Response**:
  ```json
  {
    "recognized": true,
    "person_id": 1,
    "name": "Priya",
    "relationship": "Daughter",
    "confidence": 0.91
  }
  ```
- **Unknown Response**:
  ```json
  {
    "recognized": false,
    "message": "Person not recognized."
  }
  ```

### `POST /chat`
- **Request**: `{"question": "Where does Priya live?"}`
- **Response**: `{"answer": "Priya lives in Bangalore."}`
- **Unknown Memory Response**: `{"answer": "I don't have that information saved."}`

### `GET /reminders`
- **Response**:
  ```json
  [
    {
      "title": "Doctor appointment",
      "time": "11:00 AM"
    }
  ]
  ```

---

## 8. Hackathon Demonstration Walkthrough

1. Open Ghajini 2.0 app -> **Home Screen** appears with title and "Doctor appointment - 11:00 AM" reminder.
2. Tap **[ Recognize Person ]**.
3. Capture or select demo photo of Priya.
4. Screen displays **PERSON RECOGNIZED: Priya - Daughter**.
5. Return to **Home Screen**.
6. Tap **[ Ask Memory ]**.
7. Enter question: `"Where does Priya live?"` -> Displays `"Priya lives in Bangalore."`
8. Enter question: `"Who is Dr. Sharma?"` -> Displays `"Dr. Sharma is your family doctor."`
9. Enter unknown question: `"What is my favorite food?"` -> Displays `"I don't have that information saved."`
10. Return to **Home Screen** and view local reminder notification.

---

## 9. Privacy & Safety Commitments

- **100% Local**: No cloud APIs, no data sent to external servers, no paid APIs.
- **Strict Grounding**: The LLM is constrained to answer ONLY from retrieved SQLite memory facts. It will never invent or hallucinate personal facts.
- **Local Face Processing**: Face embeddings are processed exclusively on the local machine.
