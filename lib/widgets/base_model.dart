import 'package:flutter/material.dart';
import 'package:switchcalls/enum/view_state.dart';

class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.IDLE;

  set appState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  ViewState get appState => _state;
}
