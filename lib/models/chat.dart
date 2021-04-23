import 'package:intl/intl.dart';

class Chat {
  final String uid;
  final int timeInMS;
  final String lastMessage;

  Chat({this.lastMessage, this.uid, this.timeInMS});

  DateTime get time => DateTime.fromMicrosecondsSinceEpoch(timeInMS);

  String toDateString() {
    if (time.difference(DateTime.now()).inDays > 0) return 'Yesterday';
    if (time.difference(DateTime.now()).inDays > 1)
      return DateFormat.E().format(time);
    if (time.difference(DateTime.now()).inDays > 6)
      return DateFormat.yMEd().format(time);
    return DateFormat.jm().format(time);
  }
}
