import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class CommunityShareService {
  CommunityShareService._();
  static Future<void> sharePost(BuildContext context, CommunityPostModel post) async {
    final key=GlobalKey();
    final dialog=showDialog<void>(context:context,barrierDismissible:false,builder:(_)=>Center(child:Material(color:Colors.transparent,child:RepaintBoundary(key:key,child:SizedBox(width:360,child:_ShareCard(post:post))))));
    await Future<void>.delayed(const Duration(milliseconds:450));
    final boundary=key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if(boundary==null){if(context.mounted)Navigator.of(context,rootNavigator:true).pop();await dialog;return;}
    final image=await boundary.toImage(pixelRatio:3);final data=await image.toByteData(format:ui.ImageByteFormat.png);image.dispose();
    if(context.mounted)Navigator.of(context,rootNavigator:true).pop();await dialog;if(data==null)return;
    final dir=await getTemporaryDirectory();final file=File('${dir.path}/sehatak_post_${post.id.isEmpty?DateTime.now().millisecondsSinceEpoch:post.id}.png');await file.writeAsBytes(data.buffer.asUint8List(),flush:true);await Share.shareXFiles([XFile(file.path,mimeType:'image/png')],text:'منشور من منصة صحتك — الرعاية الصحية الرقمية',subject:'منشور من صحتك');
  }
}
class _ShareCard extends StatelessWidget{final CommunityPostModel post;const _ShareCard({required this.post});@override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Container(color:Colors.white,child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[Container(padding:const EdgeInsets.all(18),color:AppColors.primary,child:const Text('صحتك — منصة الرعاية الصحية',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900))),if((post.images?.isNotEmpty??false)||(post.imageUrl?.isNotEmpty??false))SizedBox(height:220,child:AppImage(imageUrl:(post.images?.isNotEmpty??false)?post.images!.first:post.imageUrl!,fit:BoxFit.cover)),Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(post.userName,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:8),Text(post.title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900)),if((post.content??'').isNotEmpty)Padding(padding:const EdgeInsets.only(top:8),child:Text(post.content!,maxLines:5,overflow:TextOverflow.ellipsis)),const SizedBox(height:12),Text('♥ ${post.likes}   تعليقات ${post.comments}',style:const TextStyle(color:Colors.black54))]))])));}
