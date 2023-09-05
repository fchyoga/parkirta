
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';

class ParkingTimerDialog extends StatelessWidget {

  ParkingTimerDialog({
    Key? key
  }) : super(key: key);




  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.all(0),
      elevation: 5,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(18.0) ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width/2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                children: [
                  const SizedBox(width: 40,),
                  const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Waktu Parkir", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16),),
              ),
                  const Spacer(),
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset("assets/images/ic_close.svg"),
                    iconSize: 16,
                  )
                ],
            ),
            const Divider(color: AppColors.cardOutline, height: 1, thickness: 1,),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30 ),
              child: SvgPicture.asset("assets/images/ic_device.svg", width: 60, height: 60),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 40, right: 40),
              child: Text("", textAlign: TextAlign.center ,style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.text)),
            ),


          ],
        )
      ),
    );
  }

}