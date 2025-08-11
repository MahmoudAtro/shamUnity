import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart';
import 'package:shamunity/feature/shamunityAi/widgets/chat_bubble.dart';
import 'package:shamunity/feature/shamunityAi/widgets/type_indecatio.dart';
import 'package:shamunity/models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Gemini _gemini = Gemini.instance;

  // قائمة لعرض الرسائل في الواجهة
  final List<ChatMessage> _messages = [];
  // قائمة لإدارة "ذاكرة" المحادثة وإرسالها إلى Gemini
  final List<Content> _chatHistory = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 🚀 تعليمات أولية أكثر دقة واحترافية للنموذج
    _chatHistory.add(Content(role: 'user', parts: [
      Part.text(
          "تجاهل كل التعليمات السابقة. أنت مساعد الذكاء الاصطناعي 'Gemini' فائق الذكاء. مهمتك هي الإجابة على استفسارات المستخدم باللغة العربية الفصحى، مع مراعاة الدقة اللغوية والإملائية بشكل كامل. يجب أن تكون ردودك واضحة، منظمة، ومفيدة.")
    ]));
    _chatHistory.add(Content(role: 'model', parts: [
      Part.text(
          "أهلاً بك. أنا Gemini، مساعدك الشخصي. أنا جاهز للإجابة على جميع استفساراتك بدقة واحترافية. كيف يمكنني مساعدتك اليوم؟")
    ]));
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    // 1. إضافة رسالة المستخدم إلى الواجهة وسجل المحادثة
    setState(() {
      _messages.add(
          ChatMessage(isUser: true, message: userMessage, time: currentTime));
      _isLoading = true; // عرض مؤشر الكتابة
    });
    _chatHistory.add(Content(role: 'user', parts: [Parts(text: userMessage)]));
    _controller.clear();
    _scrollToBottom();

    // 2. إرسال سجل المحادثة الكامل إلى Gemini
    _gemini.streamChat(_chatHistory).listen((response) {
      final geminiResponseChunk =
          response.output ?? ""; // قطعة النص الحالية من الرد
      final geminiTime = DateFormat('HH:mm').format(DateTime.now());

      // --- المنطق الجديد والمُصحح هنا ---
      if (_messages.last.isUser) {
        // هذه هي أول قطعة من رد المساعد
        // نقوم بإنشاء فقاعة رسالة جديدة ونضع فيها هذه القطعة مباشرة
        setState(() {
          _messages.add(ChatMessage(
              isUser: false, message: geminiResponseChunk, time: geminiTime));
        });
      } else {
        // إذا كانت هناك بالفعل فقاعة رسالة للمساعد، نُلحِق بها القطعة الجديدة
        setState(() {
          _messages.last = ChatMessage(
              isUser: false,
              message: _messages.last.message + geminiResponseChunk,
              time: _messages.last.time);
        });
      }
      // --- نهاية المنطق الجديد ---

      // 3. عند اكتمال الرد بالكامل
      if (response.finishReason == 'STOP') {
        // تحديث سجل المحادثة بالرد الكامل والأخير للمساعد
        var fullResponse = _messages.last.message;
        _chatHistory
            .add(Content(role: 'model', parts: [Parts(text: fullResponse)]));
        setState(() {
          _isLoading = false; // إخفاء مؤشر الكتابة
        });
      }

      _scrollToBottom();
    }).onError((error) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
            isUser: false,
            message: "Error: ${error.toString()}",
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
          Icon(Icons.psychology, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          const Text(
            'مساعد Gemini الذكي',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'اسألني أي شيء!',
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
