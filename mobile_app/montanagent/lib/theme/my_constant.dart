import '../theme/app_theme.dart';

class MyConstantData {
  final double containerRadius;
  final double cardRadius;
  final double buttonRadius;

  MyConstantData({
    required this.containerRadius,
    required this.cardRadius,
    required this.buttonRadius,
  });
}

class MyConstant {
  static MyConstantData constant = MyConstantData(
    containerRadius: 8,
    cardRadius: 8,
    buttonRadius: 4,
  );

  static setConstant(MyConstantData data) {
    constant = data;
  }
}
