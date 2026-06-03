import 'package:intl/intl.dart';

import '../../config/app_config.dart';

/// Formatage des dates en français.
///
/// `initializeDateFormatting(AppConfig.locale)` doit avoir été appelé au
/// démarrage (voir `main.dart`) pour que la locale `fr_FR` soit disponible.
class DateFormatting {
  const DateFormatting._();

  /// Ex. « Lundi », « Mardi » (jour complet, première lettre en majuscule).
  static String fullWeekday(DateTime date) =>
      _capitalize(DateFormat('EEEE', AppConfig.locale).format(date));

  /// Ex. « Lun. », « Mar. » (jour abrégé).
  static String shortWeekday(DateTime date) =>
      _capitalize(DateFormat('EEE', AppConfig.locale).format(date));

  /// Ex. « Lundi 3 juin ».
  static String fullDate(DateTime date) =>
      _capitalize(DateFormat('EEEE d MMMM', AppConfig.locale).format(date));

  /// Ex. « 3 juin ».
  static String dayMonth(DateTime date) =>
      DateFormat('d MMMM', AppConfig.locale).format(date);

  /// Ex. « 14:00 » (créneau horaire).
  static String hour(DateTime date) =>
      DateFormat('HH:mm', AppConfig.locale).format(date);

  /// « Aujourd'hui » / « Demain » sinon le jour complet (« Mercredi »).
  static String relativeWeekday(DateTime date) {
    final now = DateTime.now();
    final target = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    return fullWeekday(date);
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
