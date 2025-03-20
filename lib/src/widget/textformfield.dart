import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfomrfiledbox extends StatefulWidget {
  final TextEditingController controller;
  final Color? color;
  final Decoration? decoration;
  final int? length;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? hinttext;
  final Icon? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool? enable;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? labelText;
  final void Function(String)? onChanged;

  const MyTextfomrfiledbox({
    super.key,
    required this.controller,
    this.color,
    this.decoration,
    this.keyboardType,
    this.icon,
    this.hinttext,
    this.suffixIcon,
    this.obscureText = false,
    this.length,
    this.enable,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.onChanged,
    this.labelText,
  });

  @override
  State<MyTextfomrfiledbox> createState() => _MyTextfomrfiledboxState();
}

class _MyTextfomrfiledboxState extends State<MyTextfomrfiledbox> {
  late FocusNode _focusNode;
  Color _currentBorderColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _currentBorderColor =
            _focusNode.hasFocus ? Colors.white : Colors.grey.shade300;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: widget.length,
      cursorColor: Colors.black,
      obscureText: widget.obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      enabled: widget.enable,
      inputFormatters: widget.inputFormatters,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.grey), 
        prefixIcon: widget.icon,
        suffixIcon: widget.suffixIcon,
        fillColor: Colors.white,
        filled: true,
        hintText: widget.hinttext,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: _currentBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2.0, color: _currentBorderColor),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: _currentBorderColor),
        ),
      ),
      style: TextStyle(color: widget.color),
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
