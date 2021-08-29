import 'package:flutter/material.dart';
import 'package:switchcalls/screens/messages/providers/free_message_provider.dart';
import 'package:switchcalls/models/message.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/storage_methods.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/utils/utilities.dart';

import '../views/view_image.dart';

class MessageTile extends StatefulWidget {
  const MessageTile({
    Key key,
    @required this.sender,
    @required this.model,
    @required this.message,
  }) : super(key: key);

  final User sender;
  final FreeMessageProvider model;
  final Message message;

  @override
  _MesTileState createState() => _MesTileState();
}

class _MesTileState extends State<MessageTile> {
  FileMessage _mes;
  @override
  Widget build(BuildContext context) {
    switch (widget.message.type) {
      case 'text':
        return Text(
          widget.message.message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        );

      case 'image':
        return widget.message.url != null
            ? InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewImage(
                      imageUrl: widget.message.url,
                    ),
                  ),
                ),
                child: Hero(
                  tag: 'Picture',
                  child: CachedImage(
                    widget.message.url,
                    height: 250,
                    width: 250,
                    radius: 10,
                  ),
                ),
              )
            : Text("Url was null");
      case 'file':
        _mes = FileMessage(message: widget.message);
        print('_mes status is ${_mes.message.message}');
        String fileBasePath =
            '${widget.model.chatDir}/${_mes.message.senderId}';
        // print(_mes.message.file?.name);
        return InkWell(
          onTap: () async {
            if (_mes.message.senderId == widget.sender.uid) {
              // print("User is sender");
              // print('OPENING ${_mes.message.file.path}');
              Utils.openFile(_mes.message.file.path);
            } else {
              print('Downloaded status ' + _mes.hasDownloaded.toString());
              if (widget.model.doesFileExist(_mes.message)) {
                // open file
                // print('OPENING $fileBasePath/${_mes.message.file.name}');
                Utils.openFile('$fileBasePath/${_mes.message.file.name}');
              }
            }
          },
          child: Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[800],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Switchcalls-${_mes.message.file?.name}',
                      // overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                Visibility(
                  visible: (_mes.message.senderId != widget.sender.uid &&
                      !widget.model.doesFileExist(_mes
                          .message)), //check if message user is not the sender and if message
                  child: Visibility(
                    visible: _mes.isDownloading,
                    child: IconButton(
                      icon: Icon(Icons.data_usage),
                      onPressed: () {},
                    ),
                    replacement: IconButton(
                      icon: Icon(widget.model.doesFileExist(_mes
                              .message) //if file doesn't exist showw the download icon
                          ? null
                          : Icons.file_download),
                      onPressed: () async {
                        if (widget.model.doesFileExist(_mes.message)) {
                          print(true);
                        } else {
                          print(false);
                          print('DOWNLOADING');
                          setState(() => _mes.isDownloading = true);
                          await Future.delayed(Duration(seconds: 5));
                          _mes.message =
                              await StorageMethods().downloadFile(_mes.message);
                          setState(() => _mes.isDownloading = false);
                          print('DOWNLOADED');
                          print('${_mes.message.file.path}');
                        }
                      },
                    ),
                  ),
                  replacement: Container(),
                ),
              ],
            ),
          ),
        );
      case 'contacts':
        return InkWell(
          onTap: () {},
          child: Container(
            height: 100,
            width: 250,
            child: Center(
              child: Text(
                '${widget.message.contact.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      case 'location':
        return Container(
          height: 100,
          width: 200,
          child: Center(
            child: Text(
              'My Location\nLat: ${widget.message.location.lat}\nLong: ${widget.message.location.long}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return Text(
          widget.message.message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        );
    }
  }
}
