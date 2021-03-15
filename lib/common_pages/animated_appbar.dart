import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnimatedAppBar extends StatelessWidget {
  AnimationController colorAnimationController;
  Animation colorTween, homeTween, workOutTween, iconTween, drawerTween;
  Function onPressed;

  AnimatedAppBar({
    @required this.colorAnimationController,
    @required this.onPressed,
    @required this.colorTween,
    @required this.homeTween,
    @required this.iconTween,
    @required this.drawerTween,
    @required this.workOutTween,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
            height: 80,
            child: AnimatedBuilder(
              animation: colorAnimationController,
              builder: (context, child) => AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.dehaze,
                    color: drawerTween.value,
                  ),
                  onPressed: onPressed,
                ),
                backgroundColor: colorTween.value,
                elevation: 0,
                titleSpacing: 0.0,
                title: Row(
                  children: <Widget>[
                    Text(
                      "Hello  ",
                      style: TextStyle(
                          color: homeTween.value,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1),
                    ),
                    Text(
                      'username',
                      style: TextStyle(
                          color: workOutTween.value,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Icon(
                    Icons.notifications,
                    color: iconTween.value,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage('image_url'),
                    ),
                  ),
                ],
              ),
            ),
          );
        
  }
}