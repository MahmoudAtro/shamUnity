import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/announcement/index.dart';
import 'package:shamunity/feature/announcements/index.dart';
import 'package:shamunity/logic/announcements bloc/index.dart';

class AnnouncementsDemo extends StatelessWidget {
  const AnnouncementsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnnouncementsCubit(
        announcementsApi: ApiAnnouncement(dio: Dio()),
      )..fetchAnnouncements(),
      child: const AnnouncementsScreen(),
    );
  }
}
