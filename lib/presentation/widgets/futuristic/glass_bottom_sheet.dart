import 'dart:ui';
import 'package:flutter/material.dart';
class GlassBottomSheet extends StatelessWidget {
 final Widget child; final String? title;
 const GlassBottomSheet({super.key, required this.child, this.title});
 @override Widget build(BuildContext c) {
  return ClipRRect(
   borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
   child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX:22,sigmaY:22),
    child: Container(
     padding: EdgeInsets.fromLTRB(20,10,20,20+MediaQuery.of(c).viewInsets.bottom),
     color: const Color(0xFF111827).withOpacity(.95),
     child: Column(mainAxisSize: MainAxisSize.min, children:[
      Container(width:42,height:4,margin:const EdgeInsets.only(bottom:14),
       decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(4))),
      if(title!=null) Text(title!,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w800)),
      const SizedBox(height:14), child,
     ]),
    ),
   ),
  );
 }
}