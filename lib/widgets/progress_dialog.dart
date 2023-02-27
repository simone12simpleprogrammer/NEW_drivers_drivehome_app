import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget
{
  String? message;
  ProgressDialog({this.message});

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      backgroundColor: CupertinoColors.systemGrey5,
      child: Container(
        width: 5.0,
        height: 200.0,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(23.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Platform.isAndroid ? Container(
            padding: const EdgeInsets.all(40.0),
            child: const CircularProgressIndicator(color: Colors.green),
          ) : const CupertinoActivityIndicator(
            color: CupertinoColors.systemGrey,
            radius: 37,
            animating: true,
          ),
        ),
      ),
    );
  }
}
