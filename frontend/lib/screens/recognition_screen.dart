import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  Future<void> _captureOrPickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _result = null;
        });
        _processRecognition(bytes, photo.name);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to capture the image.')),
      );
    }
  }

  // Quick demo simulator buttons for Hackathon presentation
  Future<void> _simulateDemoRecognition(String personName) async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final result = await ApiService.recognizePerson(dummyBytes, '$personName.jpg');

    setState(() {
      _isLoading = false;
      _result = result;
    });
  }

  Future<void> _processRecognition(Uint8List bytes, String filename) async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.recognizePerson(bytes, filename);

    setState(() {
      _isLoading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Recognize Person',
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
              // Image preview area
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: _selectedImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey.shade600),
                          const SizedBox(height: 12),
                          const Text(
                            'Capture or Select Photo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Capture button
              ElevatedButton.icon(
                key: const Key('capture_btn'),
                onPressed: _isLoading
                    ? null
                    : () => _captureOrPickImage(ImageSource.camera),
                icon: const Icon(Icons.camera, size: 28),
                label: const Text(
                  'Capture',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _captureOrPickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 22),
                label: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Hackathon Demo Selectors
              const Text(
                'Demo Presets (For Hackathon):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ActionChip(
                      label: const Text('Priya'),
                      onPressed: () => _simulateDemoRecognition('priya'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ActionChip(
                      label: const Text('Arun'),
                      onPressed: () => _simulateDemoRecognition('arun'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ActionChip(
                      label: const Text('Dr. Sharma'),
                      onPressed: () => _simulateDemoRecognition('doctor_sharma'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ActionChip(
                      label: const Text('Unknown'),
                      onPressed: () => _simulateDemoRecognition('stranger'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Result Display Card
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_result != null)
                _buildResultCard(_result!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final bool recognized = result["recognized"] == true;

    if (recognized) {
      final String name = result["name"] ?? "Priya";
      final String relationship = result["relationship"] ?? "Daughter";

      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF10B981), width: 2.5),
        ),
        child: Column(
          children: [
            const Text(
              'PERSON RECOGNIZED',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF047857),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065F46),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              relationship,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF047857),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEF4444), width: 2.5),
        ),
        child: const Column(
          children: [
            Text(
              'PERSON NOT RECOGNIZED',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB91C1C),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Person not recognized.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF991B1B),
              ),
            ),
          ],
        ),
      );
    }
  }
}
