import 'package:flutter/material.dart';

class AppTextStyles {
  /// Display Text (40pt, Bold)
  static const TextStyle display = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700, // Bold
    fontFamily: 'Pretendard',
  );

  /// Title Text (24pt, Bold)
  static const TextStyle title24Bold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    fontFamily: 'Pretendard',
  );

  /// Title Text (20pt, SemiBold)
  static const TextStyle title20SemiBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    fontFamily: 'Pretendard',
  );

  /// Subtitle (18pt, SemiBold)
  static const TextStyle subtitle18SemiBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    fontFamily: 'Pretendard',
  );

  /// Body Text (16pt, Regular)
  static const TextStyle body16Regular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    fontFamily: 'Pretendard',
  );

  /// Body Text (16pt, Bold)
  static const TextStyle body16Bold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    fontFamily: 'Pretendard',
  );

  /// Caption (10pt, Medium)
  static const TextStyle caption10Medium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    fontFamily: 'Pretendard',
  );

  /// Button Text (11pt, Bold)
  static const TextStyle button11Bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    fontFamily: 'Pretendard',
  );
}
