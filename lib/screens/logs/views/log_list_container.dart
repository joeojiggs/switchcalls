import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:switchcalls/constants/strings.dart';
import 'package:switchcalls/models/log.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/resources/local_db/repository/log_repository.dart';
import 'package:switchcalls/utils/call_utilities.dart';
import 'package:switchcalls/utils/permissions.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/widgets/quiet_box.dart';
import 'package:switchcalls/utils/utilities.dart';
import 'package:switchcalls/widgets/custom_tile.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/provider/user_provider.dart';

class LogListContainer extends StatefulWidget {
  const LogListContainer({Key key}) : super(key: key);
  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  AuthMethods authMethods = AuthMethods();
  UserProvider userProvider;
  Future<void> getUser() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
    SchedulerBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Log>>(
      future: LogRepository.getLogs(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          List<Log> logList = snapshot.data.reversed.toList();

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
                  trailing: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.video_call,
                        ),
                        onPressed: () async {
                          User receiver = await authMethods.getUserByProfilePic(
                              hasDialled ? _log.receiverPic : _log.callerPic);

                          return await Permissions
                                  .cameraAndMicrophonePermissionsGranted()
                              ? CallUtils.dial(
                                  from: userProvider.getUser,
                                  to: receiver,
                                  context: context,
                                )
                              : {};
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.phone,
                        ),
                        onPressed: () async {
                          User receiver = await authMethods.getUserByProfilePic(
                              hasDialled ? _log.receiverPic : _log.callerPic);
                          if (await Permissions
                              .cameraAndMicrophonePermissionsGranted())
                            return CallUtils.dialAudio(
                              from: userProvider.getUser,
                              to: receiver,
                              context: context,
                            );
                          return;
                        },
                      )
                    ],
                  ),
                );
              },
            );
          }
          return QuietBox(isCall: true);
        }

        return Container();
      },
    );
  }
}
