import 'package:flutter/material.dart';

import 'package:themotorwash/theme_constants.dart';

class BadgeWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  const BadgeWidget(
      {Key? key,
      required this.text,
      this.textStyle,
      this.backgroundColor,
      this.height,
      this.width,
      this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          // boxShadow: [
          //   BoxShadow(
          //       offset: Offset(0, 1),
          //       blurRadius: 4,
          //       color: Color.fromRGBO(0, 0, 0, 0.25))
          // ],
          color: backgroundColor ?? SizeConfig.kBadgeColor,
          borderRadius: borderRadius ?? BorderRadius.circular(2)),
      child: Text(
        text,
        style: textStyle ??
            TextStyle(fontSize: 10, color: SizeConfig.kPrimaryColor),
      ),
    );
  }
}
