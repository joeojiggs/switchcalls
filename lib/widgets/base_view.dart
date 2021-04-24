import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_model.dart';

class BaseView<T extends BaseModel> extends StatefulWidget {
  final T model;
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;
  final Function(T) onModelFinished;

  const BaseView(
      {Key key, this.builder, this.onModelReady, this.onModelFinished, this.model})
      : super(key: key);
  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<BaseView<T>> {

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(widget.model);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.onModelFinished != null) {
      widget.onModelFinished(widget.model);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => widget.model,
      child: Consumer<T>(builder: widget.builder),
    );
  }
}
