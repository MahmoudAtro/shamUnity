import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/library/library_api.dart';
import 'package:shamunity/core/network/dio_factory.dart';
import 'package:shamunity/feature/library/department_view.dart';
import 'package:shamunity/feature/library/widget/add_book_widget.dart';
import 'package:shamunity/logic/library%20bloc/library_cubit.dart';
import 'package:shamunity/logic/library%20bloc/library_state.dart';
import 'package:shamunity/models/library_model.dart' show LibraryModel;

class LibraryHomeScreen extends StatelessWidget {
  const LibraryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibraryCubit(LibraryApi(dio: DioFactory.getDio())),
      child: LibraryHomeView(),
    );
  }
}

class LibraryHomeView extends StatefulWidget {
  const LibraryHomeView({super.key});

  @override
  State<LibraryHomeView> createState() => _LibraryHomeViewState();
}

class _LibraryHomeViewState extends State<LibraryHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LibraryCubit>().fetchLibraryInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'library_add_book_button',
        onPressed: () => _showAddBookSheet(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة كتاب', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          if (state is LibraryInitial) {
            return _buildInitialView(context);
          }

          if (state is LibraryLoading) {
            return _buildLoadingView();
          }

          if (state is LibraryFailure) {
            return _buildFailureView(context, state.message);
          }

          if (state is LibrarySuccess) {
            return _buildSuccessView(context, state.libraries);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'اضغط على زر التحديث لجلب البيانات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshLibrary(context),
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري تحميل البيانات...'),
        ],
      ),
    );
  }

  Widget _buildFailureView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'خطأ: $message',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshLibrary(context),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, List<LibraryModel> libraries) {
    return RefreshIndicator(
      onRefresh: () => _refreshLibrary(context),
      child: LibrariesGridScreen(libraries: libraries),
    );
  }

  Future<void> _refreshLibrary(BuildContext context) async {
    try {
      // إظهار مؤشر التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري تحديث البيانات...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 1),
        ),
      );

      // تحديث البيانات
      await context.read<LibraryCubit>().fetchLibraryInfo();

      // رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث البيانات بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث البيانات: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddBookSheet(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    if (cubit.state is LibrarySuccess) {
      final libraries = (cubit.state as LibrarySuccess).libraries;
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: AddBookSheet(libraries: libraries),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى انتظار تحميل البيانات')),
      );
    }
  }
}

class LibrariesGridScreen extends StatelessWidget {
  final List<LibraryModel> libraries;

  const LibrariesGridScreen({Key? key, required this.libraries})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: libraries.length,
      itemBuilder: (context, index) {
        final library = libraries[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DepartmentsGridScreen(
                  departments: library.departments,
                  libraryName: library.name,
                ),
              ),
            );
          },
          child: Container(
            alignment: FractionalOffset.bottomCenter,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  library.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${library.departments.length} قسم',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
