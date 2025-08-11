import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // For Markdown rendering
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Gemini _gemini = Gemini.instance;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  void _sendMessage() {
    if (_controller.text.isEmpty || _isLoading) return;

    final userMessage = _controller.text;
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    setState(() {
      _messages.add(
          ChatMessage(isUser: true, message: userMessage, time: currentTime));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    final generationConfig = GenerationConfig(
      temperature: 0.7, // للتحكم في إبداع النموذج
    );

    _gemini.streamGenerateContent(
      userMessage,
      generationConfig: generationConfig,
    ).listen((response) {
      final geminiResponseChunk = response.output ?? "Error: No response";

      if (_messages.last.isUser) {
        setState(() {
          _messages.add(ChatMessage(
              isUser: false,
              message: geminiResponseChunk,
              time: DateFormat('HH:mm').format(DateTime.now())));
        });
      } else {
        setState(() {
          _messages.last = ChatMessage(
              isUser: false,
              message: _messages.last.message + geminiResponseChunk,
              time: _messages.last.time);
        });
      }
      _scrollToBottom();
    }, onDone: () {
      setState(() {
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
            isUser: false,
            // ✨ التحسين: رسالة خطأ أفضل للمستخدم
            message: "عذراً، حدث خطأ ما. يرجى المحاولة مرة أخرى.",
            time: DateFormat('HH:mm').format(DateTime.now())));
      });
      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini ✨'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                // ✨ التحسين: واجهة بداية في حال عدم وجود رسائل
                ? buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          if (_isLoading) const TypingIndicator(),
          _buildInputField(),
        ],
      ),
    );
  }

  Center buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          const Text(
            'أهلاً بك!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ المحادثة بإرسال رسالة.',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                // ✨ التحسين: تعطيل الحقل أثناء انتظار الرد
                enabled: !_isLoading,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      _isLoading ? 'المساعد يكتب...' : 'اكتب رسالتك هنا...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: const Color(0xFF0D1117),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✨ التحسين: تغيير شكل الزر وتعطيله أثناء التحميل
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isLoading ? null : _sendMessage,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                disabledBackgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ويدجت الرسائل والطباعة (تم تحسينها) ---
class ChatMessage {
  final bool isUser;
  final String message;
  final String time;

  ChatMessage(
      {required this.isUser, required this.message, required this.time});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // ✨ التحسين: إضافة ميزة النسخ عند الضغط مطولاً
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.message));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ الرسالة!')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ التحسين: استخدام Markdown لعرض النص بشكل منسق
            MarkdownBody(
              data: message.message,
              selectable: true, // للسماح بالتحديد
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(color: Colors.white),
                code: const TextStyle(
                    backgroundColor: Colors.black26, color: Colors.amber),
                // يمكنك إضافة تنسيقات أخرى هنا
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                message.time,
                style: TextStyle(
                    fontSize: 10, color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF21262D),
            radius: 16,
            child: Icon(Icons.support_agent, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            '...يكتب الآن',
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
