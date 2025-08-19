# نظام البحث في ShamUnity

## نظرة عامة
نظام البحث يتيح للمستخدمين البحث عن المستخدمين الآخرين في التطبيق باستخدام أسماءهم أو معلوماتهم.

## المكونات

### 1. API Layer
- **`api_search.dart`**: يحتوي على `ApiSearch` class الذي يتعامل مع طلبات البحث للخادم
- يستخدم endpoint: `/users/search?query={search_term}`

### 2. Business Logic Layer
- **`search_cubit.dart`**: يحتوي على `SearchCubit` الذي يدير حالة البحث
- **`search_state.dart`**: يحتوي على حالات البحث المختلفة
- **`index.dart`**: ملف تصدير لجميع مكونات البحث

### 3. UI Layer
- **`search_screen.dart`**: الصفحة الرئيسية للبحث
- **`user_card.dart`**: بطاقة عرض معلومات المستخدم
- **`index.dart`**: ملف تصدير لجميع widgets

## الميزات

### البحث المباشر
- البحث يتم تلقائياً عند الكتابة
- تأخير 500 مللي ثانية لتجنب طلبات API متكررة
- إمكانية مسح البحث

### عرض النتائج
- عرض المستخدمين في بطاقات قابلة للنقر
- عرض صورة المستخدم، الاسم، الكلية، والتخصص
- رسائل مناسبة للحالات المختلفة (تحميل، خطأ، لا توجد نتائج)

### التنقل
- النقر على بطاقة المستخدم يؤدي إلى صفحة الملف الشخصي
- زر العودة للصفحة السابقة

## الاستخدام

### إضافة أيقونة البحث
```dart
IconButton(
  icon: const Icon(Icons.search, color: Colors.white),
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  },
)
```

### استخدام SearchCubit
```dart
BlocProvider(
  create: (context) => getit<SearchCubit>(),
  child: SearchScreen(),
)
```

## التكامل مع النظام

### Service Locator
تم تسجيل `SearchCubit` و `ApiSearch` في `services_locator.dart`:
```dart
void _search() {
  getit.registerLazySingleton<ApiSearch>(
    () => ApiSearch(dio: DioFactory.getDio()),
  );
  getit.registerFactory(() => SearchCubit(getit()));
}
```

### API Constants
تم إضافة endpoint البحث في `api_constant.dart`:
```dart
static const String searchUrl = "$_baseUrl/users/search";
```

## حالات البحث

1. **SearchInitial**: الحالة الأولية - عرض رسالة "ابدأ بالكتابة"
2. **SearchLoading**: أثناء البحث - عرض مؤشر التحميل
3. **SearchLoaded**: تم العثور على نتائج - عرض قائمة المستخدمين
4. **SearchError**: حدث خطأ - عرض رسالة الخطأ مع زر إعادة المحاولة

## الأمان
- جميع طلبات البحث تتطلب token مصادقة
- يتم إرسال الـ token في header Authorization
- التعامل مع الأخطاء بشكل آمن

## الأداء
- استخدام debouncing لتجنب طلبات API متكررة
- Factory pattern لـ SearchCubit لإنشاء نسخة جديدة لكل استخدام
- Lazy loading للـ API service
