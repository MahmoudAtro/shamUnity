import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

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
@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFF21262D),
          radius: 18,
          child: Icon(Icons.support_agent, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 12),
        AnimatedTextKit(
          animatedTexts: [
            WavyAnimatedText(
              '...يكتب الآن',
              textStyle:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
            ),
          ],
          isRepeatingAnimation: true,
        ),
      ],
    ),
  );
}
