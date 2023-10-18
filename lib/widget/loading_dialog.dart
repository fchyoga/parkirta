
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';

class LoadingDialog extends StatelessWidget {
  BuildContext? parentContext;
  bool showing=false;
  final bool cancelable;
  final String? message;
  var count = 0;

  LoadingDialog({
    Key? key,
    this.cancelable = false,
    this.message
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.colorPrimary,
              strokeWidth: 6,
            ),
          )
        ],
      ),
    );
  }

  show(BuildContext context) {
    parentContext = context;
    showing = true;
    if(count==0){
      _showLoadingDialog(context, this).then((_) {
        showing = false;
      });
    }
    count++;
  }

  hide() {
    try{
      count--;
      if(count==0 && Navigator.of(parentContext!).canPop()) Navigator.of(parentContext!).pop();
    }on Exception catch (_, e){
      print("error $e");
    }
  }

}


Future _showLoadingDialog(BuildContext c, LoadingDialog loading,
    {bool cancelable = true}) =>
    showDialog(
        context: c,
        barrierDismissible: false,
        builder: (BuildContext c) => Center(child: loading));

