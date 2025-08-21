import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamunity/constants/api_constant.dart';

// كلاس لحفظ حالة التحميل
class DownloadProgress {
  final double progress;
  final bool isDownloading;
  final bool isComplete;
  final String statusText;
  final bool hasError;

  DownloadProgress({
    this.progress = 0.0,
    this.isDownloading = true,
    this.isComplete = false,
    this.statusText = "جاري تحميل الملف...",
    this.hasError = false,
  });

  DownloadProgress copyWith({
    double? progress,
    bool? isDownloading,
    bool? isComplete,
    String? statusText,
    bool? hasError,
  }) {
    return DownloadProgress(
      progress: progress ?? this.progress,
      isDownloading: isDownloading ?? this.isDownloading,
      isComplete: isComplete ?? this.isComplete,
      statusText: statusText ?? this.statusText,
      hasError: hasError ?? this.hasError,
    );
  }
}

Future<void> downloadPDF(BuildContext context, String pdfUrl) async {
  final ValueNotifier<DownloadProgress> progressNotifier = 
      ValueNotifier(DownloadProgress());

  try {
    // بناء الرابط الكامل
    final url = Uri.parse(ApiConstances.baseUrlImg).resolve(pdfUrl).toString();
    final fileName = pdfUrl.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final savePath = "${dir.path}/$fileName";

    // إظهار Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ValueListenableBuilder<DownloadProgress>(
          valueListenable: progressNotifier,
          builder: (context, downloadState, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة الحالة
                  if (downloadState.isDownloading)
                    const CircularProgressIndicator()
                  else if (downloadState.isComplete)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    )
                  else
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 48,
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // نص الحالة
                  Text(
                    downloadState.statusText,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // شريط التقدم
                  if (downloadState.isDownloading) ...[
                    LinearProgressIndicator(
                      value: downloadState.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${(downloadState.progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  // زر الإغلاق
                  if (!downloadState.isDownloading) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: downloadState.isComplete 
                              ? Colors.green 
                              : Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("إغلاق"),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    try {
      // بدء التحميل
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final newProgress = received / total;
            progressNotifier.value = progressNotifier.value.copyWith(
              progress: newProgress,
            );
          }
        },
      );

      // النجاح
      progressNotifier.value = progressNotifier.value.copyWith(
        isDownloading: false,
        isComplete: true,
        statusText: "✅ تم تحميل الملف بنجاح!",
        progress: 1.0,
      );

    } catch (downloadError) {
      // الخطأ
      progressNotifier.value = progressNotifier.value.copyWith(
        isDownloading: false,
        isComplete: false,
        hasError: true,
        statusText: "❌ فشل في تحميل الملف\n${downloadError.toString()}",
      );
      
      debugPrint("❌ خطأ أثناء تنزيل PDF: $downloadError");
    }

  } catch (e) {
    Navigator.of(context).pop();
    debugPrint("❌ خطأ عام: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ حدث خطأ غير متوقع")),
    );
  }
}