import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/feature/profile/widget/sheikh_post_widget.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_cubit.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_state.dart';

class SheikhProfileWidget extends StatefulWidget {
  final int userId;

  const SheikhProfileWidget({
    super.key,
    required this.userId,
  });

  @override
  State<SheikhProfileWidget> createState() => _SheikhProfileWidgetState();
}

class _SheikhProfileWidgetState extends State<SheikhProfileWidget> {
  late VisitedUserProfileCubit visitedUserProfileCubit;
  @override
  void initState() {
    super.initState();
    visitedUserProfileCubit = context.read<VisitedUserProfileCubit>();
    visitedUserProfileCubit.getVisitedUserProfile(widget.userId);
  }

  void _onChatPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح المحادثة قريباً'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitedUserProfileCubit, VisitedUserProfileState>(
      listener: (context, state) {
        // يمكن إضافة منطق إضافي هنا إذا لزم الأمر
      },
      child: BlocBuilder<VisitedUserProfileCubit, VisitedUserProfileState>(
        builder: (context, state) {
          // استدعاء getVisitedUserProfile عند أول بناء للـ widget

          if (state is VisitedUserProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
            );
          } else if (state is VisitedUserProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في جلب البيانات',
                    style: TextStyle(fontSize: 18, color: Colors.red[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<VisitedUserProfileCubit>()
                          .getVisitedUserProfile(widget.userId);
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else if (state is VisitedUserProfileLoaded) {
            final profile = state.profile;
            final author = profile.profile;

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),

                        // الصورة الشخصية مع حافة زرقاء جميلة
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            backgroundImage: author.profilePicture != null
                                ? NetworkImage(
                                    "${ApiConstances.baseUrlImg}${author.profilePicture!}")
                                : const AssetImage(
                                        'assets/images/default_avatar.jpg')
                                    as ImageProvider,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // اسم المستخدم
                        Text(
                          author.name ?? 'اسم غير متوفر',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),

                        if (author.college != null) ...[
                          Text(
                            author.college!,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                        ],
                        if (author.major != null) ...[
                          Text(
                            author.major!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                        Text(
                          author.email ?? 'بريد إلكتروني غير متوفر',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        // زر المحادثة المصغر مع تنسيق جميل
                        Container(
                          width: 200, // تصغير العرض
                          child: ElevatedButton.icon(
                            onPressed: _onChatPressed,
                            icon: const Icon(Icons.chat_bubble_outline,
                                color: Colors.white, size: 20),
                            label: const Text(
                              'ابدأ محادثة',
                              style: TextStyle(
                                fontSize: 16, // تصغير الخط
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue, // تغيير اللون إلى الأزرق
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20), // تقليل البادينج
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    25), // حواف أكثر انسيابية
                              ),
                              elevation: 4,
                              shadowColor: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TabBar(
                              indicatorColor:
                                  Colors.blue, // تغيير لون المؤشر إلى الأزرق
                              labelColor: Colors
                                  .blue, // تغيير لون النص المحدد إلى الأزرق
                              unselectedLabelColor: Colors.black,
                              labelStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              tabs: const [
                                Tab(text: "المنشورات"),
                                Tab(text: "الملفات"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // تبويب المنشورات
                              (profile.posts.isEmpty)
                                  ? const Center(
                                      child: Text("لا توجد منشورات لعرضها"),
                                    )
                                  : ListView(
                                      shrinkWrap: true,
                                      children: profile.posts
                                          .map((post) => SheikhPostWidget(
                                                post: post,
                                                author: author,
                                              ))
                                          .toList(),
                                    ),
                              // تبويب الملفات
                              (profile.libraryFiles.isEmpty)
                                  ? Center(
                                      child: Text(
                                        "لا توجد ملفات حتى الآن",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[700]),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: profile.libraryFiles.length,
                                      itemBuilder: (context, index) {
                                        final file =
                                            profile.libraryFiles[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.file_present,
                                              color: Colors.blue[600],
                                              size: 32,
                                            ),
                                            title: Text(
                                              file.title ?? 'عنوان غير متوفر',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              'النوع: ${file.type ?? 'غير محدد'}',
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                            trailing: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: file.status == 'approved'
                                                    ? Colors.green[100]
                                                    : Colors.orange[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                file.status == 'approved'
                                                    ? 'مقبول'
                                                    : 'قيد المراجعة',
                                                style: TextStyle(
                                                  color:
                                                      file.status == 'approved'
                                                          ? Colors.green[700]
                                                          : Colors.orange[700],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
