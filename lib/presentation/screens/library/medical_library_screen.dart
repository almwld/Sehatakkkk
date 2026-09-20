import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicalLibraryScreen extends StatelessWidget {
  const MedicalLibraryScreen({super.key});
  @override Widget build(BuildContext context){
    final uid=FirebaseAuth.instance.currentUser?.uid;
    if(uid==null)return const Scaffold(body:Center(child:Text('سجل الدخول أولاً')));
    return Scaffold(
      appBar:AppBar(title:const Text('المكتبة الطبية'),foregroundColor:AppColors.primary),
      body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream:FirebaseFirestore.instance.collection('document_library').where('ownerId',isEqualTo:uid).snapshots(),
        builder:(context,snap){
          if(snap.hasError)return const Center(child:Text('تعذر تحميل المكتبة حالياً'));
          if(!snap.hasData)return const Center(child:CircularProgressIndicator());
          final docs=snap.data!.docs;
          if(docs.isEmpty)return const Center(child:Text('لا توجد مستندات محفوظة في المكتبة'));
          return ListView.separated(
            padding:const EdgeInsets.all(12),itemCount:docs.length,separatorBuilder:(_,__)=>const Divider(),
            itemBuilder:(context,i){
              final d=docs[i].data();final name=(d['fileName']??'مستند طبي').toString();final url=(d['fileUrl']??'').toString();final path=(d['localPath']??'').toString();
              return ListTile(
                leading:Icon(name.toLowerCase().endsWith('.pdf')?Icons.picture_as_pdf_outlined:Icons.description_outlined,color:AppColors.primary),
                title:Text(d['title']?.toString().isNotEmpty==true?d['title'].toString():name,maxLines:2,overflow:TextOverflow.ellipsis),
                subtitle:Text(name,maxLines:1,overflow:TextOverflow.ellipsis),
                onTap:()async{
                  if(path.isNotEmpty&&await File(path).exists()){await showDialog(context:context,builder:(_)=>Dialog(child:Column(mainAxisSize:MainAxisSize.min,children:[const Padding(padding:EdgeInsets.all(16),child:Text('الملف محفوظ داخل الجهاز')),Text(path,style:const TextStyle(fontSize:10),textAlign:TextAlign.center),TextButton(onPressed:()=>Navigator.pop(context),child:const Text('إغلاق'))])));return;}
                  final lower=name.toLowerCase();
                  final isPdf=lower.endsWith('.pdf');
                  final isOffice=['.doc','.docx','.xls','.xlsx','.ppt','.pptx'].any(lower.endsWith);
                  if((isPdf||isOffice)&&url.isNotEmpty&&context.mounted){
                    final viewer='https://docs.google.com/gview?embedded=1&url='+Uri.encodeComponent(url);
                    await showDialog(context:context,builder:(_)=>Dialog(
                      insetPadding:const EdgeInsets.all(12),
                      child:SizedBox(width:double.infinity,height:MediaQuery.of(context).size.height*.82,
                        child:Column(children:[
                          Align(alignment:AlignmentDirectional.topEnd,child:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))),
                          Expanded(child:WebViewWidget(controller:WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)..loadRequest(Uri.parse(viewer)))),
                        ]))));
                  } else {
                    final uri=Uri.tryParse(url);if(uri!=null&&await canLaunchUrl(uri))await launchUrl(uri,mode:LaunchMode.externalApplication);
                  }
                },
              );
            });
        }),
    );
  }
}