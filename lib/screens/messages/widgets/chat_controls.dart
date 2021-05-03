import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:switchcalls/utils/universal_variables.dart';

import 'modal_tile.dart';

class ChatControls extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onFieldChanged;
  final Function onCameraTap, onSendTap, onMediaTap, onFileTap, onEmojiTap;
  final bool isWriting;

  const ChatControls({
    Key key,
    @required this.controller,
    @required this.onFieldChanged,
    @required this.onCameraTap,
    @required this.onSendTap,
    @required this.isWriting,
    @required this.onMediaTap,
    @required this.onFileTap,
    @required this.onEmojiTap,
  }) : super(key: key);

  @override
  _ChatControlsState createState() => _ChatControlsState();
}

class _ChatControlsState extends State<ChatControls> {
  final FocusNode textFieldFocus = FocusNode();
  bool showEmojiPicker = false;

  void showKeyboard() => textFieldFocus.requestFocus();

  void hideKeyboard() => textFieldFocus.unfocus();

  void hideEmojiContainer() => setState(() => showEmojiPicker = false);

  void showEmojiContainer() => setState(() => showEmojiPicker = true);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => addMediaModal(context, widget.onMediaTap, widget.onFileTap),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: UniversalVariables.fabGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 40.0),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: textFieldFocus,
                        onTap: () => hideEmojiContainer(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        onChanged: widget.onFieldChanged,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          hintStyle: TextStyle(
                            color: UniversalVariables.greyColor,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(50.0),
                              ),
                              borderSide: BorderSide.none),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          filled: true,
                          fillColor: UniversalVariables.separatorColor,
                        ),
                      ),
                    ),
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        if (!showEmojiPicker) {
                          // keyboard is visible
                          hideKeyboard();
                          showEmojiContainer();
                        } else {
                          //keyboard is hidden
                          showKeyboard();
                          hideEmojiContainer();
                        }
                      },
                      icon: Icon(Icons.face),
                    ),
                  ],
                ),
              ),
              widget.isWriting
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.record_voice_over),
                    ),
              widget.isWriting
                  ? Container()
                  : GestureDetector(
                      child: Icon(Icons.camera_alt),
                      onTap: widget.onCameraTap,
                    ),
              widget.isWriting
                  ? Container(
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          gradient: UniversalVariables.fabGradient,
                          shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          size: 15,
                        ),
                        onPressed: () => widget.onSendTap(),
                      ))
                  : Container()
            ],
          ),
        ),
        showEmojiPicker
            ? Container(
                child: EmojiPicker(
                bgColor: UniversalVariables.separatorColor,
                indicatorColor: UniversalVariables.blueColor,
                rows: 3,
                columns: 7,
                onEmojiSelected: (emoji, category) {
                  widget.onEmojiTap();
                  // setState(() {
                  //   widget.isWriting = true;
                  // });

                  widget.controller.text = widget.controller.text + emoji.emoji;
                },
                recommendKeywords: ["face", "happy", "party", "sad"],
                numRecommended: 50,
              ))
            : Container(),
      ],
    );
  }
}

void addMediaModal(BuildContext context, Function onMediaTap, Function onFileTap) {
  showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: UniversalVariables.blackColor,
      builder: (context) {
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Icon(
                      Icons.close,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Content and tools",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                children: <Widget>[
                  ModalTile(
                    title: "Media",
                    subtitle: "Share Photos and Video",
                    icon: Icons.image,
                    onTap: () {
                      Navigator.pop(context);
                      onMediaTap();
                    },
                  ),
                  ModalTile(
                    title: "File",
                    subtitle: "Share files",
                    icon: Icons.tab,
                    onTap: (){
                      Navigator.pop(context);
                      onFileTap();
                    },
                  ),
                 // ModalTile(
                  //  title: "Contact",
                  //  subtitle: "Share contacts",
                  //  icon: Icons.contacts,
                  //),
                 // ModalTile(
                  //  title: "Location",
                  //  subtitle: "Share a location",
                  //  icon: Icons.add_location,
                 // ),
                  // ModalTile(
                  //   title: "Schedule Call",
                  //   subtitle: "Arrange a skype call and get reminders",
                  //   icon: Icons.schedule,
                  // ),
                  // ModalTile(
                  //   title: "Create Poll",
                  //   subtitle: "Share polls",
                  //   icon: Icons.poll,
                  // )
                ],
              ),
            ),
          ],
        );
      });
}
