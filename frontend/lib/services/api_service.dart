import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  // Use localhost / 127.0.0.1 for desktop/mac, or 10.0.2.2 for Android emulator
  static const String baseUrl = "http://127.0.0.1:8000";

  // Check health status
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
    } catch (_) {}
    return false;
  }

  // Recognize person from image bytes
  static Future<Map<String, dynamic>> recognizePerson(
      Uint8List imageBytes, String filename) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/recognize'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename.isEmpty ? 'capture.jpg' : filename,
        ),
      );

      var streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "recognized": false,
          "message": "Person not recognized."
        };
      }
    } catch (e) {
      return {
        "recognized": false,
        "message": "Unable to connect to the memory service."
      };
    }
  }

  // Ask question about memories
  static Future<String> askMemory(String question) async {
    if (question.trim().isEmpty) {
      return "Please enter a question.";
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question.trim()}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? "I don't have that information saved.";
      }
    } catch (e) {
      return "Unable to connect to the memory service.";
    }

    return "Unable to connect to the memory service.";
  }

  // Fetch reminders
  static Future<List<Map<String, String>>> getReminders() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/reminders'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          "title": item["title"].toString(),
          "time": item["time"].toString(),
        }).toList();
      }
    } catch (_) {}

    // Predefined reminder fallback if backend offline
    return [
      {"title": "Doctor appointment", "time": "11:00 AM"}
    ];
  }
}
