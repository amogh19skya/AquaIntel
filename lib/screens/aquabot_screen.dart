import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/aquabot_service.dart';
import '../theme/app_theme.dart';

class AquaBotScreen extends StatefulWidget {
  final IAquaBotService? aquaBotService;

  const AquaBotScreen({super.key, this.aquaBotService});

  @override
  State<AquaBotScreen> createState() => _AquaBotScreenState();
}

class _AquaBotScreenState extends State<AquaBotScreen> {
  late final IAquaBotService _aquaBotService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isBotTyping = false;
  String? _sessionId;

  static const Color backgroundColor = AquaColors.bg;
  static const Color cardColor = AquaColors.card;
  static const Color inputColor = AquaColors.input;
  static const Color primaryBlue = AquaColors.accent;
  static const Color textBlue = AquaColors.textSecondary;

  @override
  void initState() {
    super.initState();
    _aquaBotService = widget.aquaBotService ?? AquaBotService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _sessionId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started a new conversation'),
        duration: Duration(seconds: 2),
        backgroundColor: cardColor,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = (customText ?? _messageController.text).trim();

    if (text.isEmpty || _isBotTyping) return;

    // Collect history before adding new user message
    final history = _messages.map((m) {
      return {
        'role': (m['isUser'] as bool) ? 'user' : 'assistant',
        'content': (m['message'] as String),
      };
    }).toList();

    setState(() {
      _messages.add({
        'message': text,
        'isUser': true,
      });
      _isBotTyping = true;
    });

    if (customText == null) {
      _messageController.clear();
    }

    _scrollToBottom();

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final response = await _aquaBotService.sendMessage(
        text,
        history: history,
        sessionId: _sessionId,
        userId: currentUserId,
      );

      if (mounted) {
        if (response.sessionId != null) {
          _sessionId = response.sessionId;
        }

        setState(() {
          _messages.add({
            'message': response.reply,
            'isUser': false,
          });
          _isBotTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'message': 'Sorry, I ran into an error getting an answer. Please try again.',
            'isUser': false,
          });
          _isBotTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ─────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AquaColors.bgSecondary,
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
                color: AquaColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AquaColors.accent.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AquaColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
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
                    'Domain AI Aquarium Assistant',
                    style: TextStyle(
                      color: textBlue,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_comment_outlined,
              color: Colors.white,
              size: 22,
            ),
            tooltip: 'New Conversation',
            onPressed: _messages.isEmpty ? null : _startNewChat,
          ),
        ],
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
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isBotTyping) {
                        return _buildTypingIndicator();
                      }
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AquaColors.card,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AquaColors.accent.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AquaColors.accent.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AquaColors.accent,
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
              'Your domain-restricted AI aquarium assistant.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about fish species care, feeding schedules,\nwater quality (pH/temp), and tank maintenance.',
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
                _suggestionChip('What should I feed my tropical fish?'),
                _suggestionChip('How often should I do water changes?'),
                _suggestionChip('How do I lower high pH in my tank?'),
                _suggestionChip('Can Betta fish live with Guppies?'),
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
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline_rounded, color: primaryBlue, size: 14),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: textBlue,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // TYPING INDICATOR
  // ─────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AquaBot is thinking...',
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.8),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // MESSAGE BUBBLE
  // ─────────────────────────────────────────
  Widget _buildMessage(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: isUser ? primaryBlue : cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: primaryBlue.withValues(alpha: 0.15),
                ),
        ),
        child: SelectableText(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.45,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
              color: primaryBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !_isBotTyping,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _isBotTyping ? 'AquaBot is responding...' : 'Ask AquaBot...',
                    hintStyle: TextStyle(
                      color: textBlue.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isBotTyping ? null : () => _sendMessage(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _isBotTyping
                        ? AquaColors.border
                        : AquaColors.accent,
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
