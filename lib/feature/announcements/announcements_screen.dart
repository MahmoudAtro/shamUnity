import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/widgets/fade_in_up.dart';
import 'package:shamunity/feature/announcements/widgets/announcement_card.dart';
import 'package:shamunity/logic/announcements bloc/cubit/announcements_cubit.dart';
import 'package:shamunity/logic/announcements bloc/cubit/announcements_state.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  // تعريف ألوان الهوية البصرية
  static const Color primaryColor = Color(0xFF0A2D4D);
  static const Color accentColor = Color(0xFFC8A464);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text(
      //     'قرارات الجامعة',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: Colors.blue,
      //   elevation: 2,
      //   centerTitle: true,
      // ),
      body: BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
        builder: (context, state) {
          if (state is AnnouncementsLoading || state is AnnouncementsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          } else if (state is AnnouncementsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('حدث خطأ: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AnnouncementsCubit>().fetchAnnouncements();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else if (state is AnnouncementsLoaded) {
            if (state.announcements.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد قرارات حاليًا',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            final announcements = state.announcements;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AnnouncementsCubit>().fetchAnnouncements();
              },
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: AnnouncementCard(announcement: announcements[index]),
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
}
