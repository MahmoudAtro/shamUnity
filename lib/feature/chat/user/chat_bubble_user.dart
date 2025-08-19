import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/logic/chat%20bloc/chat_bloc.dart';
import 'package:shamunity/logic/chat%20bloc/chat_event.dart';
import 'package:shamunity/models/chat_message_model.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble(
      {super.key,
      required this.message,
      required this.isMe,
      required this.conversationId});

  final ChatMessageModel message;
  final bool isMe;
  final int conversationId;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  ChatBloc get bloc => BlocProvider.of(context);
  late AudioPlayer audioPlayer;
  bool isStartRecod = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    // إجمالي مدة المقطع
    audioPlayer.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    // الموقع الحالي أثناء التشغيل
    audioPlayer.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    // لما يخلص المقطع
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isStartRecod = false;
        position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  play(urlvoice) async {
    try {
      audioPlayer.play(UrlSource(urlvoice));
      setState(() {
        isStartRecod = true;
      });
    } catch (e) {
      print(e);
    }
  }

  stop() async {
    try {
      await audioPlayer.stop();
      setState(() {
        isStartRecod = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.type == "text"
        ? buildTextMessage()
        : widget.message.type == "image"
            ? buildImageMessage()
            : buildAudioMessage();
  }

  Widget buildTextMessage() {
    return widget.isMe
        ? Slidable(
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    bloc.add(DeleteMessage(messageId: widget.message.id));
                  },
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
              ],
            ),
            child: BubbleSpecialThree(
              text: widget.message.content,
              color: const Color(0xFF1B97F3),
              tail: true,
              sent: true,
              seen: widget.message.isRead,
              isSender: widget.isMe,
              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        : BubbleSpecialThree(
            text: widget.message.content,
            color: Colors.green,
            tail: true,
            sent: true,
            seen: widget.message.isRead,
            isSender: widget.isMe,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16),
          );
  }

  Widget buildImageMessage() {
    final img = Image.network(
      "${ApiConstances.baseUrlImg}${widget.message.fileUrl}",
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        // عرض لودينج مؤقت أثناء تحميل الصورة
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    final bubble = BubbleNormalImage(
      image: img,
      tail: false,
      sent: true,
      seen: widget.message.isRead,
      isSender: !widget.isMe,
      id: widget.message.id.toString(),
    );

    return widget.isMe
        ? Slidable(
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    bloc.add(DeleteMessage(messageId: widget.message.id));
                  },
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
              ],
            ),
            child: bubble,
          )
        : bubble;
  }

  Widget buildAudioMessage() {
    final bubble = BubbleNormalAudio(
      isPlaying: isStartRecod,
      onSeekChanged: (e) {
        // TODO: تحكم في الـ seek إذا أردت
      },
      onPlayPauseButtonClick: () async {
        final isPlaying = isStartRecod;

        if (!isPlaying) {
          await play(
              "${ApiConstances.baseUrlImg}${widget.message.fileUrl}"); // شغل الملف الصوتي
        } else {
          await stop(); // وقف الصوت
        }
      },
      duration: duration.inSeconds.toDouble(),
      position: position.inSeconds.toDouble(),
      color: widget.isMe ? const Color(0xFF1B97F3) : Colors.green,
      tail: false,
      sent: true,
      seen: widget.message.isRead,
      isSender: !widget.isMe,
    );

    return widget.isMe
        ? Slidable(
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    bloc.add(DeleteMessage(messageId: widget.message.id));
                  },
                  icon: Icons.delete,
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
              ],
            ),
            child: bubble,
          )
        : bubble;
  }
}
