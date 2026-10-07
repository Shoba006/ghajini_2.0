import os
import sqlite3
from typing import List, Tuple
from database import get_all_memories

# Try importing sentence_transformers and faiss
try:
    from sentence_transformers import SentenceTransformer
    import faiss
    import numpy as np
    ST_AVAILABLE = True
except ImportError:
    ST_AVAILABLE = False
    print("[Memory Module] sentence-transformers or faiss not installed. Using fallback keyword matcher.")

class MemoryRAG:
    def __init__(self):
        self.model = None
        self.index = None
        self.memory_list = []
        if ST_AVAILABLE:
            try:
                # Use lightweight MiniLM model
                self.model = SentenceTransformer('all-MiniLM-L6-v2')
            except Exception as e:
                print(f"[Memory Module] Could not load SentenceTransformer model: {e}")
                self.model = None

    def build_index(self):
        memories_records = get_all_memories()
        self.memory_list = memories_records

        if not memories_records:
            return

        texts = [m["content"] for m in memories_records]

        if ST_AVAILABLE and self.model is not None:
            embeddings = self.model.encode(texts, convert_to_numpy=True)
            dimension = embeddings.shape[1]
            faiss.normalize_L2(embeddings)
            self.index = faiss.IndexFlatIP(dimension)
            self.index.add(embeddings)

    def retrieve_relevant_memories(self, question: str, top_k: int = 2) -> List[str]:
        self.build_index()

        if not self.memory_list:
            return []

        if ST_AVAILABLE and self.model is not None and self.index is not None:
            try:
                q_emb = self.model.encode([question], convert_to_numpy=True)
                faiss.normalize_L2(q_emb)
                distances, indices = self.index.search(q_emb, top_k)

                results = []
                for score, idx in zip(distances[0], indices[0]):
                    if idx < len(self.memory_list) and score > 0.20:
                        results.append(self.memory_list[idx]["content"])
                if results:
                    return results
            except Exception as e:
                print(f"[Memory Module] FAISS search error: {e}")

        # Fallback keyword match if ST/FAISS is unavailable or score below threshold
        q_lower = question.lower()
        matched = []
        for m in self.memory_list:
            content = m["content"]
            c_lower = content.lower()
            # Simple keyword matching logic
            words = [w.strip("?,.!") for w in q_lower.split() if len(w) > 2]
            for w in words:
                if w in c_lower and content not in matched:
                    matched.append(content)
                    break

        return matched[:top_k]

rag_system = MemoryRAG()

def retrieve_memories_for_question(question: str) -> List[str]:
    return rag_system.retrieve_relevant_memories(question)
