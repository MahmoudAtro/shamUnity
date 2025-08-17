import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/chat/conversation.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/connection_error.dart';
import 'package:shamunity/core/widgets/empty_data.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/chat/widget/chat_card_widget.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/logic/conversation%20bloc/conversation_bloc.dart';
import 'package:shamunity/logic/conversation%20bloc/conversation_event.dart';
import 'package:shamunity/logic/conversation%20bloc/conversation_state.dart';
import 'package:shamunity/models/chat_item_model.dart';
import 'package:shamunity/models/conversation_model.dart';
import 'package:shamunity/routes/extension.dart';

class UsersListWidget extends StatefulWidget {
  final List<ChatItemModel> users;

  const UsersListWidget({super.key, required this.users});

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  late ConversationsBloc conversationsBloc;
  @override
  void initState() {
    conversationsBloc = ConversationsBloc(
      conversationRepository: getit(),
      conversationPusher: ConversationPusher(),
    )..add(FetchConversations(userId: user?.id ?? 1));
    super.initState();
  }

  @override
  void dispose() {
    // إيقاف تشغيل البلوك عند التخلص من الشاشة
    conversationsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: conversationsBloc,
      child: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return buildShimmerLoading();
          }
          if (state is ConversationsError) {
            return ConnectionError(
              message: state.message,
            );
          }
          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return const EmptyData(message: 'لا توجد محادثات بعد');
            }
            return RefreshIndicator(
              onRefresh: () async {
                conversationsBloc
                    .add(FetchConversations(userId: user?.id ?? 1));

                // انتظار حتى انتهاء التحميل
                await conversationsBloc.stream
                    .firstWhere((state) => state is! ConversationsLoading);
              },
              child: ListView.builder(
                itemCount: state.conversations.length,
                itemBuilder: (_, index) {
                  return ChatCardWidget(
                    conversation:
                        user?.id == state.conversations[index].participant.id
                            ? state.conversations[index].lastMessage!.sender
                            : state.conversations[index].participant,
                    onTap: () {
                      context
                          .pushNamed('/userChatScreen',
                              arguments: ConversationResponseModel(
                                id: state.conversations[index].id,
                                participant: user?.id ==
                                        state
                                            .conversations[index].participant.id
                                    ? state.conversations[index].lastMessage!
                                        .sender
                                    : state.conversations[index].participant,
                                updatedAt: state.conversations[index].updatedAt,
                              ))
                          .then((value) async {
                        // بعد العودة من شاشة المحادثة، تحقق من صحة الاتصال وإعادة جلب المحادثات
                        debugPrint(
                            '🔁 عودة من شاشة المحادثة، إعادة تحميل البيانات');
                        conversationsBloc.add(
                          FetchConversationsAfterReturn(userId: user?.id ?? 1),
                        );
                      });
                    },
                    unreadCount: state.conversations[index].unreadCount,
                    lastMessage:
                        state.conversations[index].lastMessage?.content ?? '',
                    createdAt:
                        state.conversations[index].lastMessage?.createdAt ?? DateTime(2004) ,
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildShimmerLoading() {
    return GlobalShimmer(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, index) {
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
            ),
            title: Container(
              height: 16,
              width: 120,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 14,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4, right: 80),
              color: Colors.white,
            ),
            trailing: Container(
              height: 12,
              width: 40,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
