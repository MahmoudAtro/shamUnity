import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamunity/apis/chat/chat.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/theming/styles.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';
import 'package:shamunity/core/widgets/connection_error.dart';
import 'package:shamunity/core/widgets/empty_data.dart';
import 'package:shamunity/feature/chat/user/chat_bubble_user.dart';
import 'package:shamunity/feature/chat/user/shimmer_user_chat.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/logic/chat%20bloc/chat_bloc.dart';
import 'package:shamunity/logic/chat%20bloc/chat_event.dart';
import 'package:shamunity/logic/chat%20bloc/chat_state.dart';
import 'package:shamunity/models/conversation_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:record/record.dart';

class UserChatScreen extends StatefulWidget {
  final ConversationResponseModel conversation;

  const UserChatScreen({super.key, required this.conversation});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  late ChatBloc chatBloc;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _currentUserId;
  bool _hasText = false;
  File? image;
  final record = AudioRecorder();
  bool isRecord = false;
  int messageCount = 0;
  int currentConversation = 0;
  late bool isNewChat;

  @override
  void initState() {
    chatBloc = ChatBloc(
      chat: getit(),
      pusherService: ChatMessagePusher(),
    );
    if (widget.conversation.id != 0) {
      chatBloc.add(FetchChat(conversationId: widget.conversation.id));
    } else {
      chatBloc
          .add(CheckConversation(userId: widget.conversation.participant.id));
    }
    isNewChat = widget.conversation.id == 0;
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  chooseimage(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: ((context) {
          return Container(
            alignment: Alignment.center,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    uploadfromgallery(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.grey[850],
                        size: 28.w,
                      ),
                      Text(
                        "Gallery",
                        style:
                            TextStyle(color: Colors.grey[850], fontSize: 20.sp),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 60.w,
                ),
                InkWell(
                  onTap: () {
                    uploadfromcamera(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.grey[850],
                        size: 28.w,
                      ),
                      Text(
                        "Camera",
                        style:
                            TextStyle(color: Colors.grey[850], fontSize: 20.sp),
                      )
                    ],
                  ),
                ),
                horizontalspace(60),
                InkWell(
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_copy,
                        color: Colors.grey[850],
                        size: 28.w,
                      ),
                      Text(
                        "File",
                        style:
                            TextStyle(color: Colors.grey[850], fontSize: 20.sp),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }));
  }

  showimage(context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 400,
              padding: const EdgeInsets.all(20.0),
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                children: [
                  Image(
                    image: FileImage(image!),
                    width: 500,
                    height: 250,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: MaterialButton(
                      onPressed: () {
                        chatBloc.add(
                          SendMessage(
                            userId: widget.conversation.participant.id,
                            type: "image",
                            isNewChat: isNewChat,
                            attachment: image,
                          ),
                        );
                        context.pop();
                      },
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: const Text(
                        "Send",
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                  )
                ],
              ));
        });
  }

  uploadfromgallery(context) async {
    final pickedImg =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    try {
      if (pickedImg != null) {
        image = File(pickedImg.path);
        Navigator.pop(context);
        showimage(context);
      } else {
        print("NO img selected");
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  uploadfromcamera(context) async {
    final pickedImg = await ImagePicker().pickImage(source: ImageSource.camera);
    try {
      if (pickedImg != null) {
        image = File(pickedImg.path);
        Navigator.pop(context);
        showimage(context);
      } else {
        print("NO img selected");
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  Future<void> _loadUserId() async {
    // افترض أنك تخزن ID المستخدم بعد تسجيل الدخول
    _currentUserId = user?.id ?? 0;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 5),
      curve: Curves.easeOut,
    );
  }

  start_record() async {
    try {
      final location = await getApplicationCacheDirectory();
      if (await record.hasPermission()) {
        setState(() {
          isRecord = true;
        });
        await record.start(const RecordConfig(), path: '${location.path}.m4a');
      }
    } catch (e) {
      print(e);
    }
  }

  stoprecord() async {
    final pathRecord = await record.stop();
    setState(() {
      isRecord = false;
    });
    return File(pathRecord.toString());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => chatBloc,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: InkWell(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage: NetworkImage(
                        "${ApiConstances.baseUrlImg}${widget.conversation.participant.profilePictureUrl}"),
                    // Add a fallback for if the image fails or is null
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: widget.conversation.participant.profilePictureUrl ==
                            null
                        ? Text(
                            widget.conversation.participant.name.isNotEmpty
                                ? widget.conversation.participant.name[0]
                                : 'م',
                            style: TextStyle(
                                fontSize: 24.sp, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    widget.conversation.participant.name,
                    style: TextStyle(color: Colors.white, fontSize: 18.0.sp),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.teal,
            elevation: 0.0,
            actions: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.call), onPressed: () {}),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == "delete") {
                        deleteChannel(context);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return ['refresh', 'delete'].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              )
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/bacground_chat.png"),
                  fit: BoxFit.cover,
                  opacity: 0.5),
            ),
            child: Column(
              children: [
                Expanded(
                  child: BlocListener<ChatBloc, ChatState>(
                    listener: (context, state) {
                      if (state is ChatCheckConversation) {
                        currentConversation = state.conversationId;
                      }
                    },
                    child: BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                      if (state is ChatLoading) {
                        return ListView.builder(
                          itemCount: 6, // عدد عناصر shimmer
                          itemBuilder: (context, index) {
                            // مثال: أول 3 رسائل نصية و 2 صور و 1 صوتية
                            if (index < 3) {
                              return const MessageBubbleShimmer(
                                  isMe: true, type: "text");
                            } else if (index < 5) {
                              return const MessageBubbleShimmer(
                                  isMe: false, type: "image");
                            } else {
                              return const MessageBubbleShimmer(
                                  isMe: true, type: "audio");
                            }
                          },
                        );
                      } else if (state is ChatError) {
                        return ConnectionError(message: state.message);
                      } else if (state is ChatLoaded) {
                        isNewChat = false;
                        if (state.chats.isEmpty) {
                          return const EmptyData(message: 'المحادثة فارغة');
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                        messageCount = state.chats.length;
                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: state.chats.length,
                          itemBuilder: (context, index) {
                            final message = state.chats[index];
                            final isMe = message.sender.id == _currentUserId;
                            return MessageBubble(
                              message: message,
                              isMe: isMe,
                              conversationId: widget.conversation.id == 0
                                  ? currentConversation
                                  : widget.conversation.id,
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                ),
                _buildMessageComposer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 0.8),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    chooseimage(context);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.teal[600],
                ),

                // حقل الكتابة
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: AppTextFormField(
                      controller: _controller,
                      minlines: 1,
                      readOnly: isRecord,
                      maxLines: 4,
                      hintText: "اكتب رسالة",
                      borderRadius: 15,
                      textDirection: TextDirection.rtl,
                      hintStyle: const TextStyle(fontWeight: FontWeight.w500),
                      validator: (value) {},
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // زر إرسال أو مايك
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: _hasText
                      ? IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            chatBloc.add(
                              SendMessage(
                                  userId: widget.conversation.participant.id,
                                  content: _controller.text,
                                  isNewChat: isNewChat,
                                  type: "text"),
                            );
                            _controller.clear();
                          },
                        )
                      : IconButton(
                          icon: Icon(
                            isRecord ? Icons.stop : Icons.mic,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            if (isRecord) {
                              File? audio = await stoprecord();
                              chatBloc.add(
                                SendMessage(
                                  userId: widget.conversation.participant.id,
                                  isNewChat: isNewChat,
                                  attachment: audio,
                                  type: "audio",
                                ),
                              );
                              print("تم إرسال: $audio");
                            } else {
                              await start_record();
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  deleteChannel(context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
          size: 32,
        ),
        content: Text(
          textAlign: TextAlign.center,
          style: TextStyles.font15Regular.copyWith(fontWeight: FontWeight.bold),
          "هل انت متأكد من حذف الدردشة ؟ \n  لن تتمكن من استرجاع الدردشات بعد ذلك ",
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Text(
              'الغاء',
              style: isDarkMode
                  ? TextStyles.font14Medium
                  : TextStyles.font14Medium.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              context.pop();
              chatBloc.add(DeleteChannel(
                widget.conversation.id == 0
                    ? currentConversation
                    : widget.conversation.id,
              ));
            },
            child: Text(
              'حذف',
              style: isDarkMode
                  ? TextStyles.font14Medium
                  : TextStyles.font14Medium
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
