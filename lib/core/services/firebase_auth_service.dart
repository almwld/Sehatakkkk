import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sehatak/core/models/user_model.dart';
class FirebaseAuthService {
 static final _instance=FirebaseAuthService._internal(); factory FirebaseAuthService()=>_instance; FirebaseAuthService._internal(); final _auth=FirebaseAuth.instance; final _googleSignIn=GoogleSignIn();
 Stream<User?> get authStateChanges=>_auth.authStateChanges(); User? get currentUser=>_auth.currentUser;
 Future<User?> loginWithEmail(String email,String password) async{try{return (await _auth.signInWithEmailAndPassword(email:email.trim(),password:password.trim())).user;}on FirebaseAuthException catch(e){throw _handleAuthError(e);}}
 Future<User?> loginWithPhone(String phone,String password) async{try{return (await _auth.signInWithEmailAndPassword(email:'$phone@sehatak.com',password:password.trim())).user;}on FirebaseAuthException catch(e){throw _handleAuthError(e);}}
 Future<User?> registerWithEmail(String name,String email,String password,String phone) async{try{final r=await _auth.createUserWithEmailAndPassword(email:email.trim(),password:password.trim());await r.user?.updateDisplayName(name);return r.user;}on FirebaseAuthException catch(e){throw _handleAuthError(e);}}
 Future<User?> registerDoctor(String name,String email,String password,String phone,String specialty,String license) async{try{final r=await _auth.createUserWithEmailAndPassword(email:email.trim(),password:password.trim());await r.user?.updateDisplayName('د. $name');return r.user;}on FirebaseAuthException catch(e){throw _handleAuthError(e);}}
 Future<User?> loginWithGoogle() async{try{final g=await _googleSignIn.signIn();if(g==null)return null;final a=await g.authentication;return (await _auth.signInWithCredential(GoogleAuthProvider.credential(accessToken:a.accessToken,idToken:a.idToken))).user;}on FirebaseAuthException catch(e){throw _handleAuthError(e);}}
 Future<void> sendOTP(String phone) async=>_auth.verifyPhoneNumber(phoneNumber:phone,verificationCompleted:(c)async{await _auth.signInWithCredential(c);},verificationFailed:(e){throw _handleAuthError(e);},codeSent:(_,__) {},codeAutoRetrievalTimeout:(_){ });
 Future<User?> verifyOTP(String id,String code) async{try{return (await _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId:id,smsCode:code))).user;}on FirebaseAuthException catch(e){throw _handleAuthError(e);}}
 Future<UserModel?> getCurrentUserModel() async{final u=_auth.currentUser;if(u==null)return null;final s=await FirebaseFirestore.instance.collection('users').doc(u.uid).get();final d=s.data();return d==null?null:UserModel.fromFirestore(s.id,d);}
 Future<void> logout() async{await _googleSignIn.signOut();await _auth.signOut();}
 String _handleAuthError(FirebaseAuthException e)=>switch(e.code){'user-not-found'=>'المستخدم غير موجود','wrong-password'=>'كلمة المرور خاطئة','email-already-in-use'=>'البريد مستخدم مسبقاً','invalid-email'=>'بريد إلكتروني غير صحيح','weak-password'=>'كلمة المرور ضعيفة','network-request-failed'=>'لا يوجد اتصال بالإنترنت','too-many-requests'=>'محاولات كثيرة، حاول لاحقاً',_=>'حدث خطأ: ${e.message}'};
}
