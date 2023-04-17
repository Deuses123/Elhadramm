import 'package:flutter/cupertino.dart';

class TriangleClipper extends CustomClipper<Path> {
  final bool isRightAligned;

  TriangleClipper({required this.isRightAligned});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (isRightAligned) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height / 2);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) {
    return isRightAligned != oldClipper.isRightAligned;
  }
}
