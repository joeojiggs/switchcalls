import 'package:flutter/material.dart';
import 'package:switchcalls/constants/strings.dart';
import 'package:switchcalls/models/log.dart';
import 'package:switchcalls/resources/local_db/repository/log_repository.dart';
import 'package:switchcalls/screens/messagescreens/widgets/cached_image.dart';
import 'package:switchcalls/screens/pageviews/messages/widgets/quiet_box.dart';
import 'package:switchcalls/utils/utilities.dart';
import 'package:switchcalls/widgets/custom_tile.dart';
import 'package:call_log/call_log.dart';

class LogListContainer extends StatefulWidget {
  final bool isLocal;

  const LogListContainer({Key key, this.isLocal = false}) : super(key: key);
  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  getIcon(String callStatus) {
    Icon _icon;
    double _iconSize = 15;

    switch (callStatus) {
      case CALL_STATUS_DIALLED:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;

      case CALL_STATUS_MISSED:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
          size: _iconSize,
        );
        break;

      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
        break;
    }

    return Container(
      margin: EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  Widget getLocalIcon(CallType callStatus) {
    Icon _icon;
    double _iconSize = 15;

    switch (callStatus) {
      case CallType.outgoing:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;

      case CallType.missed:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
          size: _iconSize,
        );
        break;
      case CallType.incoming:
        _icon = Icon(
          Icons.call_received,
          color: Colors.grey,
          size: _iconSize,
        );
        break;
      default:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
          size: _iconSize,
        );
        break;
    }

    return Container(
      margin: EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  Future<Iterable<CallLogEntry>> getLocalLogs() async {
    return await CallLog.get();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocal) {
      return FutureBuilder<Iterable<CallLogEntry>>(
        future: getLocalLogs(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            List<CallLogEntry> logList = snapshot.data.toList();
            return ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context, index) {
                CallLogEntry _log = logList[index];
                return ListTile(
                  leading: getLocalIcon(_log.callType),
                  title: Text(
                    _log.name ?? _log.number,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(_log.timestamp)
                        .toString(),
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {},
                  ),
                );
              },
            );
          }
          return QuietBox();
        },
      );
    }
    return FutureBuilder<dynamic>(
      future: LogRepository.getLogs(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          List<dynamic> logList = snapshot.data;

          if (logList.isNotEmpty) {
            return ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context, i) {
                Log _log = logList[i];
                bool hasDialled = _log.callStatus == CALL_STATUS_DIALLED;

                return CustomTile(
                  leading: CachedImage(
                    hasDialled ? _log.receiverPic : _log.callerPic,
                    isRound: true,
                    radius: 45,
                  ),
                  mini: false,
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete this Log?"),
                      content:
                          Text("Are you sure you wish to delete this log?"),
                      actions: [
                        FlatButton(
                          child: Text("YES"),
                          onPressed: () async {
                            Navigator.maybePop(context);
                            await LogRepository.deleteLogs(i);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                        FlatButton(
                          child: Text("NO"),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    hasDialled ? _log.receiverName : _log.callerName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  icon: getIcon(_log.callStatus),
                  subtitle: Text(
                    Utils.formatDateString(_log.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                );
              },
            );
          }
          return QuietBox();
        }

        return Container();
      },
    );
  }
}
