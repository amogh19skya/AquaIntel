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
      SnackBar(
        content: Text('Started a new conversation'),
        duration: const Duration(seconds: 2),
        backgroundColor: AquaColors.card,
      ),
    );
  }

  Future<void> _showServerSettingsDialog() async {
    final currentUrl = await _aquaBotService.getActiveBaseUrl();
    final urlController = TextEditingController(text: currentUrl);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AquaColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.dns_rounded, color: AquaColors.accent, size: 22),
              const SizedBox(width: 8),
              Text(
                'AquaBot Server URL',
                style: TextStyle(
                  color: AquaColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure the FastAPI backend address:',
                style: TextStyle(
                  color: AquaColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                style: TextStyle(color: AquaColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. http://192.168.0.101:8000',
                  hintStyle: TextStyle(color: AquaColors.textMuted),
                  filled: true,
                  fillColor: AquaColors.input,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AquaColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _presetChip('USB (127.0.0.1)', 'http://127.0.0.1:8000', urlController),
                  _presetChip('Wi-Fi LAN', 'http://192.168.0.101:8000', urlController),
                  _presetChip('Emulator', 'http://10.0.2.2:8000', urlController),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AquaColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AquaColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  await _aquaBotService.setCustomBaseUrl(newUrl);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Server URL set to: $newUrl'),
                        backgroundColor: AquaColors.card,
                      ),
                    );
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _presetChip(String label, String url, TextEditingController controller) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 11)),
      backgroundColor: AquaColors.input,
      labelStyle: TextStyle(color: AquaColors.accent, fontWeight: FontWeight.w600),
      side: BorderSide(color: AquaColors.border),
      onPressed: () => controller.text = url,
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
        'failed': false,
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
            'failed': !response.success,
          });
          _isBotTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'message': 'Sorry, I ran into an error getting an answer. Please check your backend connection.',
            'isUser': false,
            'failed': true,
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
      backgroundColor: AquaColors.bg,

      // ─────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AquaColors.bgSecondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AquaColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
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
              child: Icon(
                Icons.auto_awesome,
                color: AquaColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AquaBot',
                    style: TextStyle(
                      color: AquaColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Domain AI Aquarium Assistant',
                    style: TextStyle(
                      color: AquaColors.textSecondary,
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
            icon: Icon(
              Icons.dns_outlined,
              color: AquaColors.textSecondary,
              size: 22,
            ),
            tooltip: 'Server Settings',
            onPressed: _showServerSettingsDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.add_comment_outlined,
              color: AquaColors.textPrimary,
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
                        isFailed: message['failed'] == true,
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
              child: Icon(
                Icons.auto_awesome,
                color: AquaColors.accent,
                size: 38,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Hi! I’m AquaBot',
              style: TextStyle(
                color: AquaColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your domain-restricted AI aquarium assistant.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AquaColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about fish species care, feeding schedules,\nwater quality (pH/temp), and tank maintenance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AquaColors.textMuted,
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
          color: AquaColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AquaColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline_rounded, color: AquaColors.accent, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: AquaColors.textSecondary,
                  fontSize: 12,
                ),
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
          color: AquaColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AquaColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AquaColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AquaBot is thinking...',
              style: TextStyle(
                color: AquaColors.textSecondary,
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
  Widget _buildMessage(String message, bool isUser, {bool isFailed = false}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AquaColors.accent
              : (isFailed
                  ? AquaColors.error.withValues(alpha: 0.12)
                  : AquaColors.card),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: Border.all(
            color: isUser
                ? AquaColors.accent
                : (isFailed
                    ? AquaColors.error.withValues(alpha: 0.4)
                    : AquaColors.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : (isFailed ? AquaColors.error : AquaColors.textPrimary),
                fontSize: 14,
                height: 1.45,
                fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (isFailed) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: _showServerSettingsDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AquaColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AquaColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, color: AquaColors.accent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Change Server IP / URL',
                        style: TextStyle(
                          color: AquaColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
            color: AquaColors.input,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AquaColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !_isBotTyping,
                  style: TextStyle(
                    color: AquaColors.textPrimary,
                    fontSize: 14,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _isBotTyping ? 'AquaBot is responding...' : 'Ask AquaBot...',
                    hintStyle: TextStyle(
                      color: AquaColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
