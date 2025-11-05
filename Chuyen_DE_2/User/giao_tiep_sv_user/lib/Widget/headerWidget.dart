import 'package:flutter/material.dart';

class Headerwidget extends StatelessWidget {
  final String url_avt;
  final String fullname;
  final String email;
  final double width;
  final Widget? chucnang;
  const Headerwidget({super.key, required this.url_avt, required this.fullname, this.chucnang, required this.email, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: width,
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black.withOpacity(0.4),
      //   width: 3),
      //   borderRadius: BorderRadius.circular(3.2)
      // ),
      // padding: EdgeInsets.symmetric(horizontal: 30,),
      child: Center(
        child: createHeader(),
      ),
    );
  }

  Widget createHeader(){
    String idUS = email.split('@')[0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            //custom avatar and info
            ClipOval(
              child: Image.asset(url_avt,fit: BoxFit.fill,width: 45,height: 45,),
            ),

            SizedBox(width: 15,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${fullname}",style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),),

                Text("${idUS}",style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),),
              ],
            )
          ],
        ),

        if(chucnang!=null) chucnang!,
        
      ],

      
    );
  }
}