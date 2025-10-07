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
}

class MyShadowPosition {
  static const bottom = MyShadowPosition._(0, 1);
  static const top = MyShadowPosition._(0, -1);
  static const left = MyShadowPosition._(-1, 0);
  static const right = MyShadowPosition._(1, 0);

  final double x, y;

  const MyShadowPosition._(this.x, this.y);
}
