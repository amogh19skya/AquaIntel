```dart
import 'package:flutter/material.dart';

class AquaBotScreen extends StatefulWidget {
  const AquaBotScreen({super.key});

  @override
  State<AquaBotScreen> createState() => _AquaBotScreenState();
}

class _AquaBotScreenState extends State<AquaBotScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final List<Map<String, dynamic>> _messages = [];

  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color inputColor = Color(0xFF163B5A);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'message': text,
        'isUser': true,
      });
    });

    _messageController.clear();

    // TODO:
    // Connect AquaBot AI backend here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ─────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────
      appBar: AppBar(
        backgroundColor: topColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF29A8DF),
                    Color(0xFF1B8FC4),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AquaBot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Aquarium Assistant',
                  style: TextStyle(
                    color: textBlue,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          // ─────────────────────────────────────
          // CHAT AREA
          // ─────────────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      20,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];

                      return _buildMessage(
                        message['message'],
                        message['isUser'],
                      );
                    },
                  ),
          ),

          // ─────────────────────────────────────
          // MESSAGE INPUT
          // ─────────────────────────────────────
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // WELCOME SCREEN
  // ─────────────────────────────────────────

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF29A8DF),
                    Color(0xFF1B8FC4),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 38,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Hi! I’m AquaBot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Your smart aquarium assistant.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Ask me about fish care, feeding,\nwater conditions and aquarium health.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.65),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // Suggested questions
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _suggestionChip('What should I feed my fish?'),
                _suggestionChip('How often should I change water?'),
                _suggestionChip('What pH is suitable for fish?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SUGGESTION CHIP
  // ─────────────────────────────────────────

  Widget _suggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _messageController.text = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: textBlue,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // MESSAGE BUBBLE
  // ─────────────────────────────────────────

  Widget _buildMessage(String message, bool isUser) {
    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isUser ? primaryBlue : cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // MESSAGE INPUT
  // ─────────────────────────────────────────

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          12,
        ),
        child: Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 6,
            top: 6,
            bottom: 6,
          ),
          decoration: BoxDecoration(
            color: inputColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [

              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask AquaBot...',
                    hintStyle: TextStyle(
                      color: textBlue.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF29A8DF),
                        Color(0xFF1B8FC4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
