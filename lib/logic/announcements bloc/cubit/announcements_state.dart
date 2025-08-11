import 'package:shamunity/models/announcement.dart';

abstract class AnnouncementsState {}

class AnnouncementsInitial extends AnnouncementsState {}

class AnnouncementsLoading extends AnnouncementsState {}

class AnnouncementsLoaded extends AnnouncementsState {
  final List<Announcement> announcements;
  AnnouncementsLoaded(this.announcements);
}

class AnnouncementsError extends AnnouncementsState {
  final String message;
  AnnouncementsError(this.message);
}
