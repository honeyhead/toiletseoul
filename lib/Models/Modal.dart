import 'package:flutter/material.dart';

class Modal{
   mainBottomSheet(BuildContext context){
     showModalBottomSheet(
         context: context,
         builder: ((BuildContext context){
           return new Container(
               child: new Padding(
                   padding: const EdgeInsets.all(32.0),
                   child: new Text('This is the modal bottom sheet. Tap anywhere to dismiss.',
                       textAlign: TextAlign.center,
                       style: new TextStyle(
                           color: Theme.of(context).accentColor,
                           fontSize: 24.0
                       )
                   )
               )
             );
         })
     );
   }
}