import 'package:flutter/material.dart';

/// ودجت تبويبات قابلة لإعادة الاستخدام
/// يمكن استخدامها في أي مكان في التطبيق
class ReusableTabWidget extends StatelessWidget {
  final List<String> tabTitles;
  final List<Widget> tabContents;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final double tabBarHeight;
  final double tabBarViewHeight;
  final EdgeInsetsGeometry? tabBarPadding;
  final EdgeInsetsGeometry? tabBarViewPadding;
  final bool enableScroll;

  const ReusableTabWidget({
    super.key,
    required this.tabTitles,
    required this.tabContents,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.tabBarHeight = 500,
    this.tabBarViewHeight = 500,
    this.tabBarPadding,
    this.tabBarViewPadding,
    this.enableScroll = false,
  }) : assert(tabTitles.length == tabContents.length,
            'يجب أن يكون عدد العناوين مساوياً لعدد المحتويات');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabTitles.length,
      child: Column(
        children: [
          // تبويبات جميلة مع ظل
          Padding(
            padding:
                tabBarPadding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding:
                  tabBarPadding ?? const EdgeInsets.symmetric(vertical: 12),
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
                indicatorColor: indicatorColor ?? Colors.blue,
                labelColor: labelColor ?? Colors.blue,
                unselectedLabelColor: unselectedLabelColor ?? Colors.black,
                labelStyle:
                    labelStyle ?? const TextStyle(fontWeight: FontWeight.bold),
                tabs: tabTitles.map((title) => Tab(text: title)).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // محتوى التبويبات
          SizedBox(
            height: tabBarViewHeight,
            child: TabBarView(
              physics: enableScroll
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: tabContents,
            ),
          ),
        ],
      ),
    );
  }
}

/// ودجت تبويب منشورات وملفات قابلة لإعادة الاستخدام
class PostsAndFilesTabWidget extends StatelessWidget {
  final List<Widget> posts;
  final List<Widget> files;
  final String noPostsMessage;
  final String noFilesMessage;
  final double height;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;

  const PostsAndFilesTabWidget({
    super.key,
    required this.posts,
    required this.files,
    this.noPostsMessage = "لا توجد منشورات لعرضها",
    this.noFilesMessage = "لا توجد ملفات حتى الآن",
    this.height = 500,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTabWidget(
      tabTitles: const ["المنشورات", "الملفات"],
      tabContents: [
        // تبويب المنشورات
        posts.isEmpty
            ? Center(child: Text(noPostsMessage))
            : ListView(
                shrinkWrap: true,
                children: posts,
              ),

        // تبويب الملفات
        files.isEmpty
            ? Center(
                child: Text(
                  noFilesMessage,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: files.length,
                itemBuilder: (context, index) => files[index],
              ),
      ],
      tabBarHeight: height,
      tabBarViewHeight: height,
      indicatorColor: indicatorColor,
      labelColor: labelColor,
      unselectedLabelColor: unselectedLabelColor,
    );
  }
}

/// ودجت تبويب عامة مع محتوى مخصص
class CustomTabWidget extends StatelessWidget {
  final List<TabItem> tabs;
  final double height;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final EdgeInsetsGeometry? padding;

  const CustomTabWidget({
    super.key,
    required this.tabs,
    this.height = 500,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTabWidget(
      tabTitles: tabs.map((tab) => tab.title).toList(),
      tabContents: tabs.map((tab) => tab.content).toList(),
      tabBarHeight: height,
      tabBarViewHeight: height,
      indicatorColor: indicatorColor,
      labelColor: labelColor,
      unselectedLabelColor: unselectedLabelColor,
      tabBarPadding: padding,
    );
  }
}

/// نموذج لتبويب واحد
class TabItem {
  final String title;
  final Widget content;

  const TabItem({
    required this.title,
    required this.content,
  });
}
