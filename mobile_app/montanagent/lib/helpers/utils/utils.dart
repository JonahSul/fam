class Utils {
  static String getTimeStringFromDateTime(DateTime dateTime, {bool showSecond = false}) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    if (showSecond) {
      final second = dateTime.second.toString().padLeft(2, '0');
      return '$hour:$minute:$second';
    }
    return '$hour:$minute';
  }
}
