import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCommentsView extends StatelessWidget {
  const ShimmerCommentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _commentShimmer();
        });
  }

  Widget _commentShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة البروفايل (دائرة)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المستخدم (خط غامق)
                    Container(
                      height: 12,
                      width: 100,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 6),
                    // نص التعليق
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 6),
                    // وقت التعليق
                    Container(
                      height: 10,
                      width: 60,
                      color: Colors.grey.shade300,
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
}
