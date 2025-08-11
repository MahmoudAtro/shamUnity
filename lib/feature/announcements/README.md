# صفحة الإعلانات (Announcements)

## الوصف
صفحة لعرض قرارات الجامعة والإعلانات المهمة مع دعم للملفات المرفقة (صور، مستندات، فيديو).

## الملفات
- `announcements_screen.dart` - الصفحة الرئيسية
- `widgets/announcement_card.dart` - بطاقة الإعلان
- `announcements_demo.dart` - صفحة تجريبية مع BlocProvider

## كيفية الاستخدام

### 1. في الصفحة الرئيسية للتطبيق
```dart
import 'package:shamunity/feature/announcements/announcements_demo.dart';

// في Navigator أو Routes
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AnnouncementsDemo()),
);
```

### 2. مع BlocProvider مخصص
```dart
import 'package:shamunity/feature/announcements/index.dart';
import 'package:shamunity/logic/announcements bloc/index.dart';
import 'package:shamunity/apis/announcement/index.dart';

BlocProvider(
  create: (context) => AnnouncementsCubit(
    announcementsApi: ApiAnnouncement(dio: Dio()),
  )..fetchAnnouncements(),
  child: const AnnouncementsScreen(),
)
```

## الميزات
- ✅ عرض الإعلانات مع التصميم الجميل
- ✅ دعم الصور المرفقة
- ✅ دعم المستندات والفيديو
- ✅ تحديث تلقائي (Pull to Refresh)
- ✅ معالجة الأخطاء
- ✅ حالات التحميل
- ✅ حركات انتقالية جميلة

## الألوان المستخدمة
- `primaryColor`: #0A2D4D (أزرق داكن)
- `accentColor`: #C8A464 (ذهبي)
- `lightBackgroundColor`: #F5F5F5 (رمادي فاتح)
