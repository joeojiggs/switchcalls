import 'package:intl/intl.dart';

class Chat {
  final String uid;
  final int timeInMS;
  final String lastMessage;

  Chat({this.lastMessage, this.uid, this.timeInMS});

  DateTime get time => DateTime.fromMicrosecondsSinceEpoch(timeInMS);

  String toDateString() {
    int difference = DateTime.now().difference(time).inDays;
    if (difference == 1) return 'Yesterday';
    if (difference > 1 && difference < 7) return DateFormat.E().format(time);
    if (difference >= 7) return DateFormat.yMEd().format(time);
    return DateFormat.jm().format(time);
  }
}
