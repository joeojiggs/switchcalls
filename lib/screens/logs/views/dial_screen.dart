import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class DialScreen extends StatefulWidget {
  @override
  _DialScreenState createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  TextEditingController controller = TextEditingController();
  String phoneNumber = '';
  // var controller = new MaskedTextController(mask: '0000 000 0000');

  @override
  void initState() {
    controller.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: TextField(
                    readOnly: true,
                    controller: controller,
                    textAlign: TextAlign.center,
                    // inputFormatters: [maskFormatter],
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.backspace),
                        color: UniversalVariables.greyColor,
                        onPressed: () {
                          int len = controller.text.length;
                          if (len > 0)
                            controller.text =
                                controller.text.substring(0, len - 1);
                        },
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    _buildCallDigits('1', controller),
                    _buildCallDigits('2', controller),
                    _buildCallDigits('3', controller),
                  ],
                ),
                Row(
                  children: [
                    _buildCallDigits('4', controller),
                    _buildCallDigits('5', controller),
                    _buildCallDigits('6', controller),
                  ],
                ),
                Row(
                  children: [
                    _buildCallDigits('7', controller),
                    _buildCallDigits('8', controller),
                    _buildCallDigits('9', controller),
                  ],
                ),
                Row(
                  children: [
                    _buildCallDigits('*', controller),
                    _buildCallDigits('0', controller),
                    _buildCallDigits('#', controller),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              shape: CircleBorder(),
              elevation: 20,
              child: GestureDetector(
                onTap: () async {
                  debugPrint('CALLING');
                  await FlutterPhoneDirectCaller.callNumber(controller.text);
                  controller.clear();
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: UniversalVariables.fabGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Icon(
                      Icons.call,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // DialPad(
          //   enableDtmf: true,
          //   dialButtonIconColor: UniversalVariables.blueColor,
          //   buttonTextColor: Colors.white,
          //   backspaceButtonIconColor: Colors.white,
          //   buttonColor: UniversalVariables.senderColor,
          // ),
        ],
      ),
    );
  }

  Expanded _buildCallDigits(String digit, TextEditingController control) {
    return Expanded(
      child: InkWell(
        onTap: () {
          control.text = control.text + digit;
        },
        child: Container(
          height: 80,
          // color: Colors.red,
          alignment: Alignment.center,
          child: Text(
            digit.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}