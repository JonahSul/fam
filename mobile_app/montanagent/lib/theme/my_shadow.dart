import 'package:flutter/material.dart';

class MyShadow {
  final Color? color;
  final int alpha;
  final double spreadRadius;
  final double blurRadius;
  final Offset? offset;

  const MyShadow({
    this.color,
    this.alpha = 30,
    this.spreadRadius = 0,
    this.blurRadius = 3,
    this.offset,
  });

  static const MyShadow elevation0 = MyShadow(
    alpha: 0,
    blurRadius: 0,
    spreadRadius: 0,
  );

  static const MyShadow elevation1 = MyShadow(
    alpha: 20,
    blurRadius: 2,
    spreadRadius: 0,
    offset: Offset(0, 1),
  );

  static const MyShadow elevation2 = MyShadow(
    alpha: 25,
    blurRadius: 3,
    spreadRadius: 0,
    offset: Offset(0, 1),
  );

  static const MyShadow elevation3 = MyShadow(
    alpha: 30,
    blurRadius: 4,
    spreadRadius: 0,
    offset: Offset(0, 2),
  );

  static const MyShadow elevation4 = MyShadow(
    alpha: 35,
    blurRadius: 5,
    spreadRadius: 0,
    offset: Offset(0, 2),
  );

  static const MyShadow elevation6 = MyShadow(
    alpha: 40,
    blurRadius: 6,
    spreadRadius: 0,
    offset: Offset(0, 3),
  );

  static const MyShadow elevation8 = MyShadow(
    alpha: 45,
    blurRadius: 8,
    spreadRadius: 1,
    offset: Offset(0, 3),
  );

  static const MyShadow elevation9 = MyShadow(
    alpha: 50,
    blurRadius: 9,
    spreadRadius: 1,
    offset: Offset(0, 3),
  );

  static const MyShadow elevation12 = MyShadow(
    alpha: 55,
    blurRadius: 12,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );

  static const MyShadow elevation16 = MyShadow(
    alpha: 60,
    blurRadius: 16,
    spreadRadius: 3,
    offset: Offset(0, 4),
  );

  static const MyShadow elevation24 = MyShadow(
    alpha: 65,
    blurRadius: 24,
    spreadRadius: 4,
    offset: Offset(0, 5),
  );
}
