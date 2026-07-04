import 'package:intl/intl.dart';

String getDateEN(DateTime dateTime) {
  String day = DateFormat.d().format(dateTime);
  String month = DateFormat.MMMM('en').format(dateTime);
  String year = DateFormat.y().format(dateTime);
  String weekday = DateFormat.EEEE('en').format(dateTime);

  String formattedDate =
      '$day $month $year, $weekday, ${DateFormat("HH:mm").format(dateTime)}';

  return formattedDate;
}
