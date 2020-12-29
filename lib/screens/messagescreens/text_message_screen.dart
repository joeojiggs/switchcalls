import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/appbar.dart';

class TextScreen extends StatefulWidget {
  final SmsThread thread;

  const TextScreen({Key key, this.thread}) : super(key: key);
  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  SmsSender sender = new SmsSender();
  SimCardsProvider provider = new SimCardsProvider();

  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  ScrollController _listScrollController = ScrollController();

  bool isWriting = false;

  bool showEmojiPicker = false;
  Radius messageRadius = Radius.circular(10);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: CustomAppBar(
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
          widget.thread.contact.fullName ?? widget.thread.contact.address,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.phone,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              controller: _listScrollController,
              reverse: true,
              itemCount: widget.thread.messages.length,
              itemBuilder: (context, index) {
                SmsMessage _message = widget.thread.messages[index];
                // mention the arrow syntax if you get the time
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Container(
                    alignment: _message.kind == SmsMessageKind.Sent
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(top: 12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65),
                      decoration: BoxDecoration(
                        color: _message.kind == SmsMessageKind.Sent
                            ? UniversalVariables.senderColor
                            : UniversalVariables.receiverColor,
                        borderRadius: BorderRadius.only(
                          topLeft: _message.kind == SmsMessageKind.Sent
                              ? messageRadius
                              : Radius.zero,
                          bottomRight: _message.kind == SmsMessageKind.Sent
                              ? Radius.zero
                              : messageRadius,
                          topRight: messageRadius,
                          bottomLeft: messageRadius,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          _message.body,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          chatControls(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
        ],
      ),
    );
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    sendMessage() async {
      List<SimCard> cards = await provider.getSimCards();
      SimCard currentCard = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                SimCard card = cards[index];
                return ListTile(
                  leading: Icon(
                    Icons.sim_card,
                    color: UniversalVariables.blueColor,
                  ),
                  title: Text(
                    "SIM ${card.slot}",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    // currentCard = card;
                    Navigator.pop(context);
                    return card;
                  },
                );
              },
            ),
          );
        },
      );
      var text = textFieldController.text;

      sender.sendSms(
        SmsMessage(widget.thread.contact.address, text),
        simCard: currentCard,
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  textCapitalization: TextCapitalization.sentences,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
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
                    suffixIcon: IconButton(
                      color: UniversalVariables.blueColor,
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
                  ),
                ),
              ],
            ),
          ),
          isWriting
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
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }
}
