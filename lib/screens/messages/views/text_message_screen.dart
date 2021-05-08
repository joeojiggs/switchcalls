import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:sms/sms.dart';
import 'package:switchcalls/provider/local_message_provider.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/appbar.dart';
import 'package:switchcalls/screens/messages/widgets/phone_number_field.dart';
import 'package:provider/provider.dart';
import 'package:sms/contact.dart';

class TextScreen extends StatefulWidget {
  final Contact contact;
  final List<SmsMessage> messages;

  const TextScreen({Key key, this.contact, this.messages}) : super(key: key);
  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  TextEditingController textFieldController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  ScrollController _listScrollController = ScrollController();
  final SmsSender sender = new SmsSender();
  MessageProvider _messageProvider;
  Contact _contact;
  SimCardsProvider provider = new SimCardsProvider();
  List<SmsMessage> _messages;

  bool isWriting = false;

  bool showEmojiPicker = false;
  Radius messageRadius = Radius.circular(10);

  @override
  void initState() {
    _messageProvider = Provider.of<MessageProvider>(context, listen: false);
    _contact = widget.contact;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: buildAppBar(context),
        body: Column(
          children: <Widget>[
            _messageList(),
            chatControls(),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    print(_contact);
    if (_contact == null) {
      return PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 70),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'New Conversation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                PhoneNumberField(
                  controller: contactController,
                  onEditingComplete: () async {
                    _contact = await ContactQuery().queryContact(
                      contactController.text,
                    ); //08100300345
                    // Contact(
                    //   contactController.text,
                    //   firstName: contactController.text,
                    //   lastName: '',
                    // );
                    print('contsct id $_contact');
                    setState(() {});
                    FocusScope.of(context).nextFocus();
                  },
                )
              ],
            ),
          ),
        ),
      );
    }
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
        _contact.fullName ?? _contact.address,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.phone,
          ),
          onPressed: () async {
            await FlutterPhoneDirectCaller.callNumber(_contact.address);
          },
        )
      ],
    );
  }

  Flexible _messageList() {
    if (widget.messages == null || widget.messages.isEmpty) {
      return Flexible(
            child: Center(
              child: Text('You have no conversations yet'),
            ),
          );
    } else {
      return Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              controller: _listScrollController,
              reverse: true,
              itemCount: _messages?.length ?? widget.messages.length,
              itemBuilder: (context, index) {
                SmsMessage _message = _messages != null
                    ? _messages[index]
                    : widget.messages[index];
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
          );
    }
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

    void sendMessage() async {
      List<SimCard> cards = (await provider.getSimCards())
          .where((element) => element.state == SimCardState.Ready)
          .toList();
      SimCard currentCard = cards.length < 2
          ? cards[0]
          : await showModalBottomSheet(
              context: context,
              builder: (context) {
                print(cards);
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

      var stuff = await sender.sendSms(
        SmsMessage(_contact.address, text),
        simCard: currentCard,
      );
      print('resut is ${stuff.state}');




      _messages = (await _messageProvider.getthreads())
          .where((element) => element.contact.firstName == _contact.firstName)
          .first
          .messages;
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
