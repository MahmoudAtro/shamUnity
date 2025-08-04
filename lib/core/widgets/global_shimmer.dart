import 'package:flutter/material.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shimmer/shimmer.dart';

class GlobalShimmer extends StatelessWidget {
  final Widget child;

  const GlobalShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        // baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      baseColor: ColorsManager.lightGray,
        // highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        highlightColor: Colors.white,
        child: child);
  }
}
