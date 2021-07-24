import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/models/message.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/screens/messages/providers/free_message_provider.dart';
import 'package:switchcalls/screens/messages/widgets/chat_controls.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/utils/utilities.dart';
import 'package:switchcalls/widgets/appbar.dart';

import '../widgets/message_tile.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthMethods _authMethods = AuthMethods();
  ScrollController _listScrollController = ScrollController();

  User sender;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user) {
      setState(() {
        sender = User(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoUrl,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FreeMessageProvider>(
      create: (context) => new FreeMessageProvider(receiver: widget.receiver),
      builder: (context, provider) {
        return Consumer<FreeMessageProvider>(
          builder: (context, model, child) {
            model.getDir();
            return PickupLayout(
              scaffold: Scaffold(
                backgroundColor: UniversalVariables.blackColor,
                appBar: customAppBar(context, model),
                body: Column(
                  children: <Widget>[
                    Flexible(
                      child: messageList(model, sender),
                    ),
                    // model.imageUploadProvider?.getViewState ==
                    //             ViewState.LOADING ??
                    //         false
                    //     ? Container(
                    //         alignment: Alignment.centerRight,
                    //         margin: EdgeInsets.only(right: 15),
                    //         child: CircularProgressIndicator(),
                    //       )
                    //     : Container(),
                    ChatControls(
                      controller: model.textFieldController,
                      isWriting: model.isWriting,
                      onCameraTap: () => model.pickImage(
                          source: ImageSource.camera,
                          sender: sender,
                          receiver: widget.receiver),
                      onEmojiTap: () => model.setWritingTo(true),
                      onFieldChanged: (val) {
                        (val.length > 0 && val.trim() != "")
                            ? model.setWritingTo(true)
                            : model.setWritingTo(false);
                      },
                      onMediaTap: () => model.pickImage(
                          source: ImageSource.gallery,
                          sender: sender,
                          receiver: widget.receiver),
                      onSendTap: () =>
                          model.sendMessage(sender, widget.receiver),
                      onFileTap: () => model.pickFile(sender, widget.receiver),
                      onContactTap: () =>
                          model.pickContact(context, sender, widget.receiver),
                      onLocationTap: () =>
                          model.getLocation(sender, widget.receiver),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget messageList(FreeMessageProvider model, User sender) {
    return StreamBuilder<List<Message>>(
      stream: model.messageStream(sender?.uid),
      builder: (context, AsyncSnapshot<List<Message>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data.isEmpty)
          return Center(
            child: Text(
              'You do not have any messages at this moment!',
              style: TextStyle(
                color: UniversalVariables.greyColor,
              ),
            ),
          );
        // print('Data is ${snapshot.data.map((e) => e.message).toList()}');
        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            // mention the arrow syntax if you get the time
            return chatMessageItem(model, snapshot.data[index], sender);
          },
        );
      },
    );
  }

  Widget chatMessageItem(FreeMessageProvider model, Message _mes, User sender) {
    // Message _mes = Message.fromMap(snapshot);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _mes.senderId == sender.uid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _mes.senderId == sender.uid
            ? senderLayout(model, _mes)
            : receiverLayout(model, _mes),
      ),
    );
  }

  Widget senderLayout(FreeMessageProvider model, Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  MessageTile(sender: sender, model: model, message: message),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    Utils.convertTimeStampToHumanDate(
                        int.parse(message.timestamp.seconds.toString())),
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0)),
                Text(" | "),
                Text(
                    Utils.convertTimeStampToHumanHour(
                        int.parse(message.timestamp.seconds.toString())),
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0)),
                Text(" "),
                Icon(
                  Icons.done,
                  color: UniversalVariables.blueColor,
                  size: 15,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget receiverLayout(FreeMessageProvider model, Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  MessageTile(sender: sender, model: model, message: message),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    Utils.convertTimeStampToHumanDate(
                        int.parse(message.timestamp.seconds.toString())),
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0)),
                Text(" | "),
                Text(
                    Utils.convertTimeStampToHumanHour(
                        int.parse(message.timestamp.seconds.toString())),
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0)),
                Text(" "),
              ],
            )
          ],
        ),
      ),
    );
  }

  CustomAppBar customAppBar(BuildContext context, FreeMessageProvider model) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        widget.receiver.name,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.video_call,
          ),
          onPressed: () => model.makeCall(context, true, sender),
        ),
        IconButton(
          icon: Icon(
            Icons.phone,
          ),
          onPressed: () => model.makeCall(context, false, sender),
        ),
      ],
    );
  }
}

