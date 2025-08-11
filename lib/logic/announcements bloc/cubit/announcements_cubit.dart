import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/announcement/api_announcement.dart';
import 'package:shamunity/models/announcement.dart';

import 'announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final ApiAnnouncement announcementsApi;
  final AnnouncementPusherService _pusherService = AnnouncementPusherService();
  List<Announcement> announcements = [];
  StreamSubscription<Map<String, dynamic>>? _announcementSubscription;

  AnnouncementsCubit({required this.announcementsApi})
      : super(AnnouncementsInitial()) {
    debugPrint("🔄 AnnouncementsCubit initialized");
    _initializePusher();
  }

  Future<void> _initializePusher() async {
    debugPrint("🔄 AnnouncementsCubit: Initializing Pusher...");
    try {
      await _pusherService.initPusher();
      debugPrint("✅ AnnouncementsCubit: Pusher initialized successfully");
      _listenToRealTimeUpdates();
      debugPrint("✅ AnnouncementsCubit: Real-time updates listener started");
    } catch (e) {
      debugPrint("❌ AnnouncementsCubit: Failed to initialize Pusher: $e");
    }
  }

  void _listenToRealTimeUpdates() {
    debugPrint("🔄 AnnouncementsCubit: Setting up stream listeners...");

    _announcementSubscription = _pusherService.announcementStream.listen((announcementData) {
      debugPrint("📡 AnnouncementsCubit: Received announcement update: $announcementData");
      if (!isClosed) {
        _handleAnnouncementUpdate(announcementData);
      } else {
        debugPrint("⚠️ AnnouncementsCubit: Cubit is closed, ignoring announcement update");
      }
    });

    debugPrint("✅ AnnouncementsCubit: Stream listeners set up successfully");
  }

  void _handleAnnouncementUpdate(Map<String, dynamic> announcementData) {
    debugPrint("🔄 AnnouncementsCubit: Handling announcement update: $announcementData");

    final action = announcementData['action'] as String?;
    if (action == null) {
      debugPrint("⚠️ AnnouncementsCubit: No action found in announcement data");
      return;
    }

    debugPrint("🔄 AnnouncementsCubit: Action: $action");

    switch (action) {
      case 'created':
        debugPrint("🔄 AnnouncementsCubit: Handling announcement created");
        final announcement = announcementData['announcement'] as Announcement?;
        if (announcement != null) {
          if (!announcements.any((a) => a.id == announcement.id)) {
            announcements.insert(0, announcement);
            debugPrint(
                "✅ AnnouncementsCubit: New announcement added to list, total announcements: ${announcements.length}");
            if (!isClosed) {
              emit(AnnouncementsLoaded(List.from(announcements)));
              debugPrint("✅ AnnouncementsCubit: Emitted AnnouncementsLoaded for new announcement");
            }
          } else {
            debugPrint("⚠️ AnnouncementsCubit: Announcement ${announcement.id} already exists in list");
          }
        } else {
          debugPrint("❌ AnnouncementsCubit: No announcement data found in created event");
        }
        break;

      case 'updated':
        debugPrint("🔄 AnnouncementsCubit: Handling announcement updated");
        final announcement = announcementData['announcement'] as Announcement?;
        if (announcement != null) {
          final index = announcements.indexWhere((a) => a.id == announcement.id);
          if (index != -1) {
            announcements[index] = announcement;
            debugPrint("✅ AnnouncementsCubit: Announcement ${announcement.id} updated in list");
            if (!isClosed) {
              emit(AnnouncementsLoaded(List.from(announcements)));
              debugPrint(
                  "✅ AnnouncementsCubit: Emitted AnnouncementsLoaded for updated announcement");
            }
          } else {
            debugPrint(
                "⚠️ AnnouncementsCubit: Announcement ${announcement.id} not found in list for update");
          }
        } else {
          debugPrint("❌ AnnouncementsCubit: No announcement data found in updated event");
        }
        break;

      case 'deleted':
        debugPrint("🔄 AnnouncementsCubit: Handling announcement deleted");
        final announcementId = announcementData['announcementId'] as int?;
        if (announcementId != null) {
          final initialLength = announcements.length;
          announcements.removeWhere((a) => a.id == announcementId);
          final finalLength = announcements.length;
          debugPrint(
              "✅ AnnouncementsCubit: Announcement $announcementId removed from list (${initialLength} -> ${finalLength})");
          if (!isClosed) {
            emit(AnnouncementsLoaded(List.from(announcements)));
            debugPrint("✅ AnnouncementsCubit: Emitted AnnouncementsLoaded for deleted announcement");
          }
        } else {
          debugPrint("❌ AnnouncementsCubit: No announcementId found in deleted event");
        }
        break;

      default:
        debugPrint("⚠️ AnnouncementsCubit: Unknown action: $action");
        break;
    }
  }

  Future<void> fetchAnnouncements() async {
    debugPrint("🔄 Fetching announcements from server");
    emit(AnnouncementsLoading());

    final result = await announcementsApi.getAnnouncements();
    result.fold(
      (failure) => emit(AnnouncementsError(failure.message)),
      (listAnnouncements) {
        debugPrint("✅ Server returned ${listAnnouncements.length} announcements");
        announcements = listAnnouncements;
        if (!isClosed) {
          emit(AnnouncementsLoaded(announcements));
          debugPrint("✅ Emitted AnnouncementsLoaded with ${announcements.length} announcements");
        }
      },
    );
  }

  @override
  Future<void> close() {
    _announcementSubscription?.cancel();
    return super.close();
  }
}
