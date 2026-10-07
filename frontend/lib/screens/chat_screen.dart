import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _askedQuestion;
  String? _answer;

  Future<void> _handleAsk([String? presetQuestion]) async {
    final query = presetQuestion ?? _controller.text;
    if (query.trim().isEmpty) {
      setState(() {
        _askedQuestion = null;
        _answer = "Please enter a question.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _askedQuestion = query;
      _answer = null;
    });

    final res = await ApiService.askMemory(query);

    setState(() {
      _isLoading = false;
      _answer = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Ask Memory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Input Field
              TextField(
                key: const Key('question_input'),
                controller: _controller,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Ask something about a person...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                  ),
                ),
                onSubmitted: (_) => _handleAsk(),
              ),

              const SizedBox(height: 16),

              // Ask Button
              ElevatedButton.icon(
                key: const Key('ask_btn'),
                onPressed: _isLoading ? null : () => _handleAsk(),
                icon: const Icon(Icons.send_rounded, size: 24),
                label: const Text(
                  'Ask',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Preset questions for testing/demoing
              const Text(
                'Demo Questions:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Where does Priya live?'),
                    onPressed: () {
                      _controller.text = 'Where does Priya live?';
                      _handleAsk('Where does Priya live?');
                    },
                  ),
                  ActionChip(
                    label: const Text('Who is Dr. Sharma?'),
                    onPressed: () {
                      _controller.text = 'Who is Dr. Sharma?';
                      _handleAsk('Who is Dr. Sharma?');
                    },
                  ),
                  ActionChip(
                    label: const Text('Who is Arun?'),
                    onPressed: () {
                      _controller.text = 'Who is Arun?';
                      _handleAsk('Who is Arun?');
                    },
                  ),
                  ActionChip(
                    label: const Text('What is my favorite food?'),
                    onPressed: () {
                      _controller.text = 'What is my favorite food?';
                      _handleAsk('What is my favorite food?');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Display Area for Question & Answer
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_answer != null)
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_askedQuestion != null) ...[
                        const Text(
                          'Question',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _askedQuestion!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Divider(height: 32, thickness: 1.2),
                      ],
                      const Text(
                        'Answer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _answer!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
