import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/logic/suggestion%20cubit/suggestion_cubit.dart';
import 'package:shamunity/logic/suggestion%20cubit/suggestion_state.dart';
import 'package:shamunity/routes/extension.dart'; // تأكد من إضافة هذه المكتبة للحصول على تحريكات Lottie

// تصنيف نوع الملاحظة
enum FeedbackType { suggestion, complaint, bug, question }

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  // متغيرات التحريك
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // متغيرات الحالة
  FeedbackType _selectedType = FeedbackType.suggestion;
  final TextEditingController _textController = TextEditingController();
  bool _isSending = false;
  bool _showSuccess = false;

  // حالة التركيز على حقل النص
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  // تعيين اسم النوع بالعربية
  Map<FeedbackType, String> typeNames = {
    FeedbackType.suggestion: 'اقتراح',
    FeedbackType.complaint: 'شكوى',
    FeedbackType.bug: 'خطأ في التطبيق',
    FeedbackType.question: 'سؤال',
  };

  // ألوان مختلفة لكل نوع
  Map<FeedbackType, Color> typeColors = {
    FeedbackType.suggestion: Colors.blue,
    FeedbackType.complaint: Colors.orange,
    FeedbackType.bug: Colors.red,
    FeedbackType.question: Colors.green,
  };

  late SuggestionCubit suggestionCubit;

  @override
  void initState() {
    super.initState();
    suggestionCubit = SuggestionCubit(getit());
    // إعداد التحريكات
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // التعامل مع حالة التركيز
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    // بدء التحريك
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    suggestionCubit.close();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // دالة لمعالجة ضغط زر الإرسال
  void _submitFeedback() async {
    // التحقق من وجود محتوى
    if (_textController.text.trim().isEmpty) {
      _showError('الرجاء كتابة ملاحظاتك قبل الإرسال');
      return;
    }

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    suggestionCubit.sendSuggestion(_selectedType.name, _textController.text);
  }

  // الحصول على رسالة نجاح مخصصة
  String _getSuccessMessage() {
    switch (_selectedType) {
      case FeedbackType.suggestion:
        return 'تم تقديم اقتراحك بنجاح، شكراً لمساهمتك في تحسين التطبيق!';
      case FeedbackType.complaint:
        return 'تم تسجيل شكواك بنجاح، سنعمل على حلها في أقرب وقت.';
      case FeedbackType.bug:
        return 'شكراً على الإبلاغ عن الخطأ، سيتم مراجعته من قبل فريق التطوير.';
      case FeedbackType.question:
        return 'تم استلام سؤالك، وسنقوم بالرد عليك قريباً.';
    }
  }

  // عرض رسالة خطأ
  void _showError(String message) {
    // تحريك اهتزاز للحقل
    _shakeTextField();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  // تحريك اهتزاز لحقل النص
  void _shakeTextField() {
    const double shakeOffset = 10.0;
    const Duration shakeDuration = Duration(milliseconds: 500);

    final AnimationController controller = AnimationController(
      duration: shakeDuration,
      vsync: this,
    );

    Tween(
      begin: 0.0,
      end: shakeOffset,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward(from: 0.0);

    // تحديث حالة الواجهة أثناء التحريك
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: suggestionCubit,
      child: BlocListener<SuggestionCubit, SuggestionState>(
        listener: (context, state) {
          if (state is SuggestionLoading) {
            setState(() {
              _isSending = true;
              _showSuccess = false;
            });
          }
          if (state is SuggestionFailure) {
            context.pop();
            Toast().error(context, state.message);
          }
          if (state is SuggestionSuccess) {
            setState(() {
              _isSending = false;
              _showSuccess = true;
            });
          }
        },
        child: Scaffold(
          // backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              color: Colors.black.withOpacity(0.5), // خلفية شفافة
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    // خلفية قابلة للنقر لإغلاق الشاشة
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isSending && !_showSuccess) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),

                    // المحتوى الرئيسي
                    Align(
                      alignment: Alignment.center,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 24.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: _showSuccess
                                  ? _buildSuccessView()
                                  : _buildFeedbackForm(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء نموذج الملاحظات
  Widget _buildFeedbackForm() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان ووصف
          Center(
            child: Column(
              children: [
                Text(
                  'شاركنا رأيك',
                  style: TextStyle(
                    color: ColorsManager.gold,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'نقدر ملاحظاتك وآرائك لتحسين تجربتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // نوع الملاحظة
          Text(
            'نوع الملاحظة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),

          // أزرار اختيار النوع
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: FeedbackType.values.map((type) {
                final bool isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? typeColors[type]!.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? typeColors[type]!
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        typeNames[type]!,
                        style: TextStyle(
                          color: isSelected ? typeColors[type] : Colors.black54,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20.h),

          // حقل النص
          Text(
            'اكتب ملاحظتك',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.white,
              border: Border.all(
                color: _isFocused
                    ? typeColors[_selectedType]!
                    : Colors.grey.withOpacity(0.3),
                width: _isFocused ? 2 : 1,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: typeColors[_selectedType]!.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 5,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                contentPadding: EdgeInsets.all(16.w),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // زر الإرسال
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isSending ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColors[_selectedType],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: _isSending
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 18),
                          SizedBox(width: 8.w),
                          Text(
                            'إرسال',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء شاشة النجاح
  Widget _buildSuccessView() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رسم متحرك للنجاح
          // يمكنك تحميل ملفات Lottie من https://lottiefiles.com/
          SizedBox(
            height: 150.h,
            child: Lottie.asset(
              'assets/images/success.json', // تأكد من وجود هذا الملف
              repeat: false,
              animate: true,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'تم الإرسال بنجاح',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: ColorsManager.gold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _getSuccessMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.gold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'العودة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
