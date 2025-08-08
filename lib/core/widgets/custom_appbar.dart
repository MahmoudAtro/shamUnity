import 'package:flutter/material.dart';
import 'package:shamunity/core/theming/styles.dart';
import 'package:shamunity/routes/extension.dart';


class CustomAppbar extends StatelessWidget {
  final String title;
  const CustomAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title , style: TextStyles.font24BlackRegular,),
        IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(
              Icons.arrow_forward,
            )),
      ],
    );
  }
}