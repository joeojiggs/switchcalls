import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/provider/local_message_provider.dart';
import 'package:switchcalls/widgets/custom_tile.dart';
import 'package:switchcalls/widgets/quiet_box.dart';

import 'text_message_screen.dart';

class SMSList extends StatelessWidget {
  final bool isLoading;
  List<SmsThread> threads;
  final MessageProvider messageProvider;

  SMSList({Key key, this.isLoading, this.threads, this.messageProvider})
      : super(key: key);
  final SmsQuery query = new SmsQuery();
  // SmsSender sender = new SmsSender();
  final List colors = [
    Colors.green,
    Colors.indigo,
    Colors.yellow,
    Colors.orange
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<SmsThread>>(
        initialData: messageProvider.messages,
        stream: messageProvider.controller.stream,
        builder: (context, snapshot) {
          threads = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting &&
              threads.isEmpty)
            return Center(child: CircularProgressIndicator());
          if (threads.isNotEmpty) {
            return ListView.builder(
              itemCount: threads.length,
              itemBuilder: (__, index) {
                SmsThread _thread = threads[index];
                return _contactTiles(context, _thread);
              },
            );
          }
          return QuietBox();
        },
      ),
    );
  }

  CustomTile _contactTiles(BuildContext context, SmsThread _thread) {
    return CustomTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextScreen(
            contact: _thread.contact,
            messages: _thread.messages,
          ),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: colors[Random().nextInt(4)],
        radius: 25,
        child: _thread.contact.photo != null
            ? Image.memory(_thread.contact.photo?.bytes)
            : _thread.contact?.fullName?.isNotEmpty ?? false
                ? Text(
                    _thread.contact.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )
                : Text(
                    _thread.contact.address[0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
      ),
      title: Text(
        _thread.contact.fullName ?? _thread.contact.address,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      subtitle: Text(
        _thread.messages[0].body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
        ),
      ),
      // trailing: IconButton(
      //   icon: Icon(Icons.message),
      //   onPressed: () {},
      // ),
    );
  }
}
