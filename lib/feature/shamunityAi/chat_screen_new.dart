import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // For Markdown rendering
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ✨✨✨ 1. تبسيط الدالة لتكون آمنة جداً ✨✨✨
// ستقوم هذه الدالة فقط بإصلاح المسافات بعد علامات الترقيم
// ✨ دالة التصحيح النهائية والمحسّنة ✨
String fixMessageSpacing(String text) {
  // القاعدة الأولى: إصلاح المسافات بعد علامات الترقيم (قاعدة آمنة وموجودة حاليًا)
  String fixedText = text.replaceAllMapped(
    RegExp(r'([.!؟،])([^\s])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );

  // ✨ القاعدة الثانية (اختيارية وآمنة): إصلاح الكلمات المنتهية بتاء مربوطة ة
  // هذه القاعدة تبحث عن أي تاء مربوطة ملتصقة بحرف عربي وتضيف بينهما مسافة
  // مثال: "المكتبةالجديدة" -> "المكتبة الجديدة"
  fixedText = fixedText.replaceAllMapped(
    RegExp(r'(ة)([\u0621-\u064A])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );

  return fixedText;
}

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
      temperature: 0.7,
    );

    _gemini
        .streamGenerateContent(
      userMessage,
      generationConfig: generationConfig,
    )
        .listen((response) {
      final geminiResponseChunk = response.output ?? "Error: No response";

      // ✨✨✨ 2. العودة إلى منطق الدمج البسيط والمباشر ✨✨✨
      if (_messages.last.isUser) {
        // إضافة أول جزء من رد المساعد
        setState(() {
          _messages.add(ChatMessage(
              isUser: false,
              message: geminiResponseChunk,
              time: DateFormat('HH:mm').format(DateTime.now())));
        });
      } else {
        // تحديث الرسالة الحالية بإضافة الجزء الجديد إليها
        setState(() {
          final updatedMessage = _messages.last.message + geminiResponseChunk;
          _messages.last = ChatMessage(
              isUser: false,
              message: updatedMessage,
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
        title: Text(
          'Chat with ShamUnity AI ✨',
          style: TextStyle(fontSize: 25.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
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
            ' ! أهلاً بك',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ المحادثة بإرسال رسالة',
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
                enabled: !_isLoading,
                onChanged: (value) => setState(() {}),
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
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isLoading || _controller.text.isEmpty ? null : _sendMessage,
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
            MarkdownBody(
              data: fixMessageSpacing(message.message),
              selectable: true,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(color: Colors.white),
                code: const TextStyle(
                    backgroundColor: Colors.black26, color: Colors.amber),
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
