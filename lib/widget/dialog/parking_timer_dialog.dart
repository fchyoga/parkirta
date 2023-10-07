
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:parkirta/utils/contsant/app_colors.dart';
import 'package:parkirta/widget/button/button_default.dart';

class ParkingTimerDialog extends StatelessWidget {

  ParkingTimerDialog({
    Key? key,
    required this.entryDate,
    required this.duration,
    required this.name,
    required this.location,
    required this.address,
    required this.price,
    required this.policeNumber,
    required this.onClickStop,
  }) : super(key: key);

  DateTime entryDate;
  String duration;
  String name;
  String location;
  String address;
  String price;
  String policeNumber;
  Function onClickStop;



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
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset("assets/images/ic_left_circle.svg"),
                    iconSize: 16,
                  ),
                  const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("Waktu Parkir", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16),),
              ),
                  const Spacer(),

                  const SizedBox(width: 40,),
                ],
            ),

            Padding(
              padding: EdgeInsets.only( top: 10, bottom: 20),
              child: Text(duration, style: const TextStyle(color: AppColors.colorPrimary, fontSize: 38, fontWeight: FontWeight.bold),),
            ),


            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Entry :", style: TextStyle(color: AppColors.text)),
                      Text(DateFormat("dd MMM yyyy HH:mm").format(entryDate), style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(width: 20,),

                ],
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Nama : ", style: TextStyle(color: AppColors.text)),
                      Text(name, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("No. Pol :", style: TextStyle(color: AppColors.text)),
                      Text(policeNumber, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                    ],
                  )

                ],
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Lokasi : ", style: TextStyle(color: AppColors.text)),
                      Text(location,
                          maxLines: 2,style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                      Text(address,
                          maxLines: 2,style: TextStyle(color: AppColors.textPassive)),
                    ],
                  )),
                  SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Tarif :", style: TextStyle(color: AppColors.text)),
                      Text("Rp ${price}", style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                    ],
                  )

                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ButtonDefault(title: "Keluar Parkiran", onTap: () => onClickStop()),
            ),




          ],
        )
      ),
    );
  }

}