import 'package:flutter/material.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class NewChatButton extends StatelessWidget {
  final Function onTap ;

  const NewChatButton({Key key, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            gradient: UniversalVariables.fabGradient,
            borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 25,
        ),
        padding: EdgeInsets.all(15),
      ),
    );
  }
}
