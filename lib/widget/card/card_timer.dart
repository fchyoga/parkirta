
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parkirta/main.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/widget/dialog/parking_timer_dialog.dart';

class CardTimer extends StatefulWidget {
  DateTime? dateTime;
  Function(String) onClick;
  CardTimer({Key? key, this.dateTime, required this.onClick}) : super(key: key);
  
  @override
  _CardTimerState createState() => _CardTimerState();
}

class _CardTimerState extends State<CardTimer> {

  String duration = "--:--:--";

  @override
  void initState() {
    startTimer(widget.dateTime ?? DateTime.now());
    debugPrint("cardtime ${widget.dateTime}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.01),
              blurRadius: 5,
              offset: const Offset(0, 12),),
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 7),),
            BoxShadow(
              color: Colors.grey.withOpacity(0.09),
              blurRadius: 3,
              offset: const Offset(0, 3),),
            BoxShadow(
              color: Colors.grey.withOpacity(0.10),
              blurRadius: 2,
              offset: const Offset(0, 1),),
          ],

        ),
        child: Column(
          children: [
            const Text("Waktu Parkir", style: TextStyle(color: AppColors.textPassive, fontSize: 10),),
            const SizedBox(height: 2,),
            Text(duration, style: const TextStyle(color: AppColors.colorPrimary, fontSize: 30, fontWeight: FontWeight.bold),),
            const SizedBox(height: 2,),
          ],
        ),
      ),
      onTap: () => widget.onClick(duration),
    );
  }
  
  void startTimer(DateTime dateTime){
    Timer.periodic(const Duration(seconds: 1), (timer) {
      var now = DateTime.now();
      var diff = now.difference(dateTime);
      setState(() {
        var second = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
        var minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
        duration = "${diff.inHours.toString().padLeft(2, '0')}:$minutes:$second";
      });
    });
  }


}
