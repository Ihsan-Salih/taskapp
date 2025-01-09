import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/open_ai_service.dart';

class OpenAIIntegrationView extends StatefulWidget {
  @override
  _OpenAIIntegrationViewState createState() => _OpenAIIntegrationViewState();
}

class _OpenAIIntegrationViewState extends State<OpenAIIntegrationView> {
  final List<String> languages = ['English', 'Japanese', 'Chinese', 'Spanish', 'French', 'German'];
  String selectedLanguage = 'English'; // Default language
  String selectedFeature = 'Text Translation'; // Default feature
  final TextEditingController _inputController = TextEditingController();
  String _aiResponse = '';
  bool _isLoading = false;

  // Generate AI response based on the selected feature
  void generateAIResponse() async {
    final openAIService = OpenAIService();

    setState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    String prompt = '';

    // Tailor prompt based on the selected feature
    switch (selectedFeature) {
      case 'Text Translation':
        prompt = '''
Transliterate and translate the following text from $selectedLanguage to English. Provide:
1. The original text in $selectedLanguage.
2. The transliteration in English.
3. The English meaning or translation.
"${_inputController.text}"
''';
        break;
      case 'Vocabulary Building':
        prompt = '''
Provide 3 common vocabulary words in $selectedLanguage for the topic "${_inputController.text}". For each word, include:
1. The original word in $selectedLanguage.
2. The transliteration in English.
3. The English meaning or translation.
4. An example sentence in $selectedLanguage and its English translation.
''';
        break;
      case 'Grammar Correction':
        prompt = '''
Correct the grammar of the following sentence in $selectedLanguage. Provide:
1. The corrected sentence in $selectedLanguage.
2. A transliterated version in English.
3. A brief explanation of the correction.
"${_inputController.text}"
''';
        break;
    }

    try {
      final result = await openAIService.getResponse(prompt);

      setState(() {
        _aiResponse = result;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _aiResponse = 'Failed to fetch response. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Copy AI response to clipboard
  void copyToClipboard() {
    if (_aiResponse.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _aiResponse));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Upto here works');
    return Scaffold(
      appBar: AppBar(
        title: Text('Language Learning Coach'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selection dropdown
            Text(
              'Select a Language:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedLanguage,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              items: languages.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Feature selection chips
            Text(
              'Select a Feature:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Text Translation',
                  'Vocabulary Building',
                  'Grammar Correction',
                ].map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(feature),
                      selected: selectedFeature == feature,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedFeature = feature;
                          });
                        }
                      },
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.grey[200],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),

            // Input field
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Enter your text here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Right-aligned Generate button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : generateAIResponse,
                child: Text('Generate Response'),
              ),
            ),
            SizedBox(height: 16),

            // AI Response display with Copy button
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_aiResponse.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _aiResponse,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: copyToClipboard,
                        tooltip: 'Copy Response',
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    'Your response will appear here.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}