import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';
import 'package:switchcalls/utils/universal_variables.dart';

class DialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DialPad(
        enableDtmf: true,
        dialButtonIconColor: UniversalVariables.blueColor,
        buttonTextColor: Colors.white,
        backspaceButtonIconColor: Colors.white,
        buttonColor: UniversalVariables.senderColor,

      ),
    );
  }
}

class DialButton extends StatefulWidget {
  final Key key;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final ValueSetter<String> onTap;
  final bool shouldAnimate;
  DialButton(
      {this.key,
      this.title,
      this.subtitle,
      this.color,
      this.textColor,
      this.icon,
      this.iconColor,
      this.shouldAnimate,
      this.onTap});

  @override
  _DialButtonState createState() => _DialButtonState();
}

class _DialButtonState extends State<DialButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _colorTween;
  Timer _timer;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _colorTween = ColorTween(
            begin: widget.color != null ? widget.color : Colors.white24,
            end: Colors.white)
        .animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.shouldAnimate == null || widget.shouldAnimate) _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;

    return GestureDetector(
      onTap: () {
        if (this.widget.onTap != null) this.widget.onTap(widget.title);

        if (widget.shouldAnimate == null || widget.shouldAnimate) {
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
            _timer = Timer(const Duration(milliseconds: 200), () {
              setState(() {
                _animationController.reverse();
              });
            });
          }
        }
      },
      child: ClipOval(
          child: AnimatedBuilder(
              animation: _colorTween,
              builder: (context, child) => Container(
                    color: _colorTween.value,
                    height: sizeFactor,
                    width: sizeFactor,
                    child: Center(
                        child: widget.icon == null
                            ? widget.subtitle != null
                                ? Column(
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Text(
                                            widget.title,
                                            style: TextStyle(
                                                fontSize: sizeFactor / 2,
                                                color: widget.textColor != null
                                                    ? widget.textColor
                                                    : Colors.white),
                                          )),
                                      Text(widget.subtitle,
                                          style: TextStyle(
                                              color: widget.textColor != null
                                                  ? widget.textColor
                                                  : Colors.white))
                                    ],
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      widget.title,
                                      style: TextStyle(
                                          fontSize: widget.title == "*" &&
                                                  widget.subtitle == null
                                              ? screenSize.height * 0.0862069
                                              : sizeFactor / 2,
                                          color: widget.textColor != null
                                              ? widget.textColor
                                              : Colors.white),
                                    ))
                            : Icon(widget.icon,
                                size: sizeFactor / 2, color: widget.iconColor != null ? widget.iconColor : Colors.white)),
                  ))),
    );
  }
}