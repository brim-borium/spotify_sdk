import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SizedIconButton extends StatelessWidget {
  final double width;
  final IconData icon;
  final VoidCallback onPressed;

  const SizedIconButton(
      {Key key,
      @required this.width,
      @required this.icon,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FlatButton(
        child: Icon(icon),
        onPressed: () => onPressed(),
      ),
    );
  }
}
