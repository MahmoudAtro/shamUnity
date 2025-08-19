import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // إضافة headers لتحسين التوافق
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
        },
        videoPlayerOptions: VideoPlayerOptions(),
      );

      // محاولة تهيئة الفيديو مع timeout أطول للأجهزة البطيئة
      await _initializeWithRetry();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _formatErrorMessage(e.toString());
      });

      // طباعة الخطأ للتشخيص
      print('Video Player Error: $e');
    }
  }

  Future<void> _initializeWithRetry() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        retryCount++;

        if (retryCount > 1) {
          // انتظار قبل إعادة المحاولة
          await Future.delayed(Duration(seconds: retryCount * 2));
        }

        await _videoPlayerController.initialize().timeout(
          Duration(
              seconds: 30 + (retryCount * 10)), // زيادة المهلة مع كل محاولة
          onTimeout: () {
            throw Exception(
                'انتهت مهلة تحميل الفيديو - المحاولة $retryCount من $maxRetries');
          },
        );

        // إذا وصلنا هنا، نجحت التهيئة
        break;
      } catch (e) {
        print('Video initialization attempt $retryCount failed: $e');

        if (retryCount >= maxRetries) {
          // فشلت جميع المحاولات
          throw e;
        }

        // إعادة تهيئة المتحكم
        await _videoPlayerController.dispose();
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
          },
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
          ),
        );
      }
    }

    // إنشاء ChewieController بعد نجاح التهيئة
    _createChewieController();
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false, // تعطيل التشغيل التلقائي لتجنب مشاكل MediaCodec
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey[300]!,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'جاري تحميل الفيديو...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'قد يستغرق هذا بضع ثوانٍ على بعض الأجهزة',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return _buildErrorWidget(errorMessage);
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'مشغل الفيديو',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يرجى الانتظار، قد يستغرق هذا بضع ثوانٍ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_chewieController != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library,
            color: Colors.white70,
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا يمكن تشغيل الفيديو',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'حدث خطأ غير متوقع',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _initializeVideoPlayer();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'خطأ في تحميل الفيديو',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializeVideoPlayer();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('إغلاق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatErrorMessage(String error) {
    if (error.contains('MediaCodec') || error.contains('OMX.MTK')) {
      return 'خطأ في تشغيل الفيديو على هذا الجهاز (MediaCodec).\n\n'
          'الحلول المقترحة:\n'
          '• أعد تشغيل التطبيق\n'
          '• تأكد من وجود مساحة كافية على الجهاز\n'
          '• جرب تشغيل الفيديو من جهاز آخر\n'
          '• تأكد من تحديث نظام التشغيل';
    } else if (error.contains('timeout') || error.contains('مهلة')) {
      return 'انتهت مهلة تحميل الفيديو.\n\n'
          'قد يكون السبب:\n'
          '• اتصال الإنترنت بطيء\n'
          '• حجم الفيديو كبير جداً\n'
          '• مشكلة في الخادم';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'خطأ في الاتصال بالشبكة.\n\n'
          'تأكد من:\n'
          '• اتصال الإنترنت مستقر\n'
          '• إعادة تشغيل التطبيق';
    }
    return 'خطأ غير متوقع في تشغيل الفيديو.\n\n'
        'تفاصيل الخطأ:\n$error';
  }
}
