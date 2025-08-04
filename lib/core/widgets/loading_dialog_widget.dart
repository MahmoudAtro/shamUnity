import 'package:flutter/material.dart';

class LoadingDialogWidget extends StatefulWidget {
  const LoadingDialogWidget({super.key});

  @override
  State<LoadingDialogWidget> createState() => _LoadingDialogWidgetState();
}

class _LoadingDialogWidgetState extends State<LoadingDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF247CFF),
      ),
    );
  }
}
