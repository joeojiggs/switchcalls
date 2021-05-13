import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class PhoneNumberField extends StatefulWidget {
  final List<Contact> suggestions;
  final TextEditingController controller;
  final VoidCallback onEditingComplete;

  const PhoneNumberField({
    Key key,
    this.suggestions,
    this.controller,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  _PhoneNumberFieldState createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final FocusNode _node = FocusNode();
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    _node.addListener(() {
      if (_node.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        // Overlay.of(context).insert(this._overlayEntry);
      } else {
        // this._overlayEntry.remove();
      }
    });
    super.initState();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 200.0,
          width: size.width,
          child: CompositedTransformFollower(
            link: this._layerLink,
            child: Material(
              elevation: 4.0,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: <Widget>[
                  ListTile(
                    title: Text('Syria'),
                  ),
                  ListTile(
                    title: Text('Lebanon'),
                  ),
                  ListTile(
                    title: Text('Syria'),
                  ),
                  ListTile(
                    title: Text('Syria'),
                  ),
                  ListTile(
                    title: Text('Syria'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: TextFormField(
        textAlignVertical: TextAlignVertical.top,
        onEditingComplete: () => widget.onEditingComplete(),
        controller: widget.controller,
        keyboardType: TextInputType.phone,
        focusNode: _node,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person_add),
          hintText: 'Add Contacts',
          suffix: InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: Icon(Icons.done),
            ),
            onTap: widget.onEditingComplete,
          ),
        ),
      ),
    );
  }
}
