import 'package:flutter/material.dart';

class CondensedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text1;
  final Widget state1;
  final String text2;
  final Widget state2;

  CondensedAppBar({this.text1, this.state1, this.text2, this.state2});
  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //title: Padding(padding: EdgeInsets.only(top: 50), child:Text('cenas'),),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      elevation: 4,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: 32, right: 20),
        child: Container(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.only(left: 50),
              child: Container(
                height: 40,
                child: Card(
                  child: Center(
                    child: state1,
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Container(
                height: 40,
                // width: double.infinity,
                child: Card(
                  child: Center(child: state2),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),

      /*  Padding(
        padding: EdgeInsets.only(left: 50, top: 32, right: 20),
        child: Container(
            child: Column(children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text1,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DefaultColors.textColorOnDark),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  // width: double.infinity,
                  child: Card(
                    child: Center(
                      child: state1,
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DefaultColors.textColorOnDark),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  // width: double.infinity,
                  child: Card(
                    child: Center(child: state2),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          )
        ])),
      ), */
    );
  }
}
