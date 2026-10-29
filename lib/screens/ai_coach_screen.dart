
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController messageController =
  TextEditingController();

  final List<Map<String, String>> messages = [
    {
      'sender': 'coach',
      'text':
      'Hey player! ⚽ I am your AI Football Coach. Ask me about shooting, passing, dribbling or training.',
    },
  ];

  bool isLoading = false;

  // API key command line se read hogi.
  static const String apiKey =
  String.fromEnvironment('GEMINI_API_KEY');

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final question = messageController.text.trim();

    if (question.isEmpty || isLoading) return;

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'API key missing. Restart the app with GEMINI_API_KEY.',
          ),
        ),
      );
      return;
    }

    setState(() {
      messages.add({
        'sender': 'user',
        'text': question,
      });
      messageController.clear();
      isLoading = true;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are AI Football Coach, a friendly assistant. '
              'Answer questions about football skills, drills, tactics, '
              'fitness and training. Keep answers beginner-friendly and concise.',
        ),
      );

      final response = await model
          .generateContent([Content.text(question)])
          .timeout(const Duration(seconds: 60));

      if (!mounted) return;

      final reply = response.text?.trim();

      setState(() {
        messages.add({
          'sender': 'coach',
          'text': reply != null && reply.isNotEmpty
              ? reply
              : 'No response received. Please try another question.',
        });
      });
    } catch (e, stackTrace) {
      debugPrint('Gemini error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        messages.add({
          'sender': 'coach',
          'text':
          'The AI request failed or timed out. '
              'Please check your internet, API key, model availability '
              'and Gemini API quota, then try again.',
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.psychology,
              color: Color(0xFFB7F34A),
            ),
            SizedBox(width: 10),
            Text('AI Football Coach'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1C261C),
            child: const Text(
              'AI FOOTBALL ASSISTANT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB7F34A),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width * 0.8,
                    ),
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFB7F34A)
                          : const Color(0xFF1C261C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: isUser
                            ? const Color(0xFF101710)
                            : Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFB7F34A),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Coach is thinking...'),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            color: const Color(0xFF1C261C),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    enabled: !isLoading,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask a football question...',
                      filled: true,
                      fillColor: const Color(0xFF101710),
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: isLoading ? null : sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFB7F34A),
                    foregroundColor: const Color(0xFF101710),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
