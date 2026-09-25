import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

extension DateTimeFormatter on String {
  String toTimeString() {
    try {
      final dateTime = DateTime.parse(this);
      return DateFormat.Hm().format(dateTime); // e.g. "21:30"
    } catch (_) {
      return '';
    }
  }

  DateTime _localDateTime(String string) {
    try {
      return DateFormat('yyyy-MM-ddTHH:mm:ssZ').parseUTC(string).toLocal();
    } catch (error) {
      return DateTime.now().toLocal();
    }
  }

  String toDateString({required String pattern}) {
    final DateTime dateTime = _localDateTime(this);
    return DateFormat(pattern).format(dateTime);
  }

  Map<String, int> getHourAndMinute(String timeString) {
    // Split the string by ":"
    List<String> parts = timeString.split(":");

    // Extract hour and minute
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    // Return hour and minute as int
    return {"hour": hour, "minute": minute};
  }

  String toMonthName(
    BuildContext context,
    String month,
  ) {
    final monthNames = {
      '01': 'January',
      '02': 'February',
      '03': 'March',
      '04': 'April',
      '05': 'May',
      '06': 'June',
      '07': 'July',
      '08': 'August',
      '09': 'September',
      '10': 'October',
      '11': 'November',
      '12': 'December',
    };

    final formattedMonth = month.padLeft(2, '0');

    return monthNames[formattedMonth] ?? 'Invalid Month';
  }
}

String timeOfDayToTimeString(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute:00'; // Add seconds if needed
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  return emailRegex.hasMatch(email);
}

Map<String, int> getHourAndMinute(String timeString) {
  // Split the string by ":"
  List<String> parts = timeString.split(":");

  // Extract hour and minute
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);

  // Return hour and minute as int
  return {"hour": hour, "minute": minute};
}

String getDayWithSuffix(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

String formatOpeningTime(String openingTime) {
  // Parse string to DateTime
  final time = DateFormat("HH:mm").parse(openingTime); // e.g., "22:00"

  // Format to "h a" → "10 PM", "8 AM"
  return DateFormat("h a").format(time);
}

String formatTimeToHour(String openingTime) {
  try {
    final time = DateFormat("HH:mm").parse(openingTime);
    return DateFormat("HH:mm")
        .format(time); // returns 24-hour format like 22:00
  } catch (e) {
    return openingTime;
  }
}

String formatEventDate(DateTime date) {
  final dayWithSuffix = getDayWithSuffix(date.day);
  final month = DateFormat.MMMM().format(date); // e.g., "May"
  return '$dayWithSuffix $month';
}

bool isClubOpen(String openingTime, String closingTime, [List<String>? workingDay]) {
  final now = DateTime.now();

  // Check working day when provided — nightclubs that open after midnight (e.g.,
  // 22:00 Fri → 05:00 Sat) are listed under the day they *open*, so we must also
  // accept "yesterday" as a valid working day for early-morning hours.
  if (workingDay != null && workingDay.isNotEmpty) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    const abbrevs = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayIndex = now.weekday - 1; // 0=Mon … 6=Sun
    final todayFull = days[todayIndex];
    final todayAbbrev = abbrevs[todayIndex];
    final yesterdayIndex = (todayIndex - 1 + 7) % 7;
    final yesterdayFull = days[yesterdayIndex];
    final yesterdayAbbrev = abbrevs[yesterdayIndex];

    bool matchesDay(String d, String full, String abbrev) {
      final lower = d.toLowerCase();
      return lower == full || lower == abbrev;
    }

    final worksToday = workingDay.any((d) => matchesDay(d, todayFull, todayAbbrev));
    final worksYesterday = workingDay.any((d) => matchesDay(d, yesterdayFull, yesterdayAbbrev));
    if (!worksToday && !worksYesterday) return false;
  }

  final openParts = getHourAndMinute(openingTime);
  final closeParts = getHourAndMinute(closingTime);

  DateTime todayOpening = DateTime(
    now.year,
    now.month,
    now.day,
    openParts["hour"]!,
    openParts["minute"]!,
  );

  DateTime todayClosing = DateTime(
    now.year,
    now.month,
    now.day,
    closeParts["hour"]!,
    closeParts["minute"]!,
  );

  // Handle clubs that close after midnight (e.g., 22:00–05:00)
  if (todayClosing.isBefore(todayOpening)) {
    if (now.isBefore(todayClosing)) {
      // It's early morning — the club opened yesterday
      todayOpening = todayOpening.subtract(const Duration(days: 1));
    } else {
      // It hasn't opened yet today — it will close tomorrow
      todayClosing = todayClosing.add(const Duration(days: 1));
    }
  }

  return now.isAfter(todayOpening) && now.isBefore(todayClosing);
}

String formatCurrency(double value) =>
    NumberFormat.currency(locale: 'ja_JP', symbol: '¥').format(value);

class DateTimeFormat {
  static const String mmmDY = 'MMM d, y';
  static const String yMMddSlash = 'y/MM/dd';
  static const String yMMddhmSlash = 'y/MM/dd h:mm';
  static const String yMMddDot = 'y.MM.dd';
  static const String jm = 'jm';
  static const String hm = 'h:mm';
  static const String hms = 'h:mm:ss a';
  static const String mmmY = 'MMM y';
  static const String mmY = 'MM y';
  static const String mmmmD = 'MMMM d';
}

extension PaddingExtensions on Widget {
  PaddingWrapper get pad => PaddingWrapper(child: this);
}

class PaddingSize {
  PaddingSize({
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsets padding;

  Padding get p2 => Padding(
        padding: padding * 2,
        child: child,
      );

  Padding get p4 => Padding(
        padding: padding * 4,
        child: child,
      );

  Padding get p6 => Padding(
        padding: padding * 6,
        child: child,
      );

  Padding get p8 => Padding(
        padding: padding * 8,
        child: child,
      );

  Padding get p10 => Padding(
        padding: padding * 10,
        child: child,
      );

  Padding get p12 => Padding(
        padding: padding * 12,
        child: child,
      );

  Padding get p16 => Padding(
        padding: padding * 16,
        child: child,
      );

  Padding get p20 => Padding(
        padding: padding * 20,
        child: child,
      );

  Padding get p22 => Padding(
        padding: padding * 22,
        child: child,
      );

  Padding get p24 => Padding(
        padding: padding * 24,
        child: child,
      );

  Padding get p30 => Padding(
        padding: padding * 30,
        child: child,
      );

  Padding get p32 => Padding(
        padding: padding * 32,
        child: child,
      );

  Padding get p36 => Padding(
        padding: padding * 36,
        child: child,
      );

  Padding get p48 => Padding(
        padding: padding * 48,
        child: child,
      );

  Padding get p56 => Padding(
        padding: padding * 56,
        child: child,
      );

  Padding get p60 => Padding(
        padding: padding * 60,
        child: child,
      );

  Padding get p72 => Padding(
        padding: padding * 72,
        child: child,
      );

  Padding get p100 => Padding(
        padding: padding * 100,
        child: child,
      );

  Padding get p180 => Padding(
        padding: padding * 180,
        child: child,
      );
}

class PaddingWrapper {
  PaddingWrapper({required this.child});

  final Widget child;

  Padding get formElement => Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      );

  PaddingSize get all => PaddingSize(
        child: child,
        padding: const EdgeInsets.all(1),
      );

  PaddingSize get top => PaddingSize(
        child: child,
        padding: const EdgeInsets.only(top: 1),
      );

  PaddingSize get bottom => PaddingSize(
        child: child,
        padding: const EdgeInsets.only(bottom: 1),
      );

  PaddingSize get right => PaddingSize(
        child: child,
        padding: const EdgeInsets.only(right: 1),
      );

  PaddingSize get left => PaddingSize(
        child: child,
        padding: const EdgeInsets.only(left: 1),
      );

  PaddingSize get horizontal => PaddingSize(
        child: child,
        padding: const EdgeInsets.only(left: 1, right: 1),
      );

  PaddingSize get vertical => PaddingSize(
        child: child,
        padding: const EdgeInsets.only(top: 1, bottom: 1),
      );
}

Color getRandomPopColor() {
  final random = Random();

  // Pop color palette: vibrant hues with good contrast
  final List<Color> popColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.amber,
    Colors.lightGreenAccent,
    Colors.greenAccent,
    Colors.tealAccent,
    Colors.cyanAccent,
    Colors.blueAccent,
    Colors.indigoAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.deepOrangeAccent,
  ];

  return popColors[random.nextInt(popColors.length)];
}
