import unittest
import json
import os
from database import init_db, get_all_people, get_all_memories, get_all_reminders
from memory import retrieve_memories_for_question
from ai import generate_answer
from face_recognition import recognize_person_from_image

class TestBackendFlow(unittest.TestCase):
    def setUp(self):
        init_db()

    def test_database_seeding(self):
        people = get_all_people()
        self.assertEqual(len(people), 3)

        memories = get_all_memories()
        self.assertEqual(len(memories), 7)

        reminders = get_all_reminders()
        self.assertEqual(len(reminders), 1)
        self.assertEqual(reminders[0]["title"], "Doctor appointment")
        self.assertEqual(reminders[0]["time"], "11:00 AM")

    def test_memory_rag_known_question(self):
        # Test Priya lives in Bangalore
        question1 = "Where does Priya live?"
        memories1 = retrieve_memories_for_question(question1)
        answer1 = generate_answer(question1, memories1)
        self.assertIn("Bangalore", answer1)

        # Test Dr. Sharma
        question2 = "Who is Dr. Sharma?"
        memories2 = retrieve_memories_for_question(question2)
        answer2 = generate_answer(question2, memories2)
        self.assertIn("doctor", answer2.lower())

    def test_memory_rag_unknown_question(self):
        # Test unknown memory
        question = "What is my favorite food?"
        memories = retrieve_memories_for_question(question)
        answer = generate_answer(question, memories)
        self.assertEqual(answer, "I don't have that information saved.")

    def test_face_recognition(self):
        dummy_bytes = b"fake_image_bytes"
        result_priya = recognize_person_from_image(dummy_bytes, "priya_sample.jpg")
        self.assertTrue(result_priya["recognized"])
        self.assertEqual(result_priya["name"], "Priya")
        self.assertEqual(result_priya["relationship"], "Daughter")

        result_stranger = recognize_person_from_image(dummy_bytes, "random_person.jpg")
        self.assertFalse(result_stranger["recognized"])
        self.assertEqual(result_stranger["message"], "Person not recognized.")

if __name__ == "__main__":
    unittest.main()
