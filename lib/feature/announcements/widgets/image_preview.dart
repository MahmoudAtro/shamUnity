import 'package:flutter/material.dart';
import 'package:shamunity/constants/api_constant.dart';

class HeroImageExample extends StatelessWidget {
  final String imageUrl;

  const HeroImageExample({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImage(imageUrl: imageUrl),
          ),
        );
      },
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            "${ApiConstances.baseUrlImg}$imageUrl",
            height: 300,
            // width: 150,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network("${ApiConstances.baseUrlImg}$imageUrl"),
          ),
        ),
      ),
    );
  }
}
