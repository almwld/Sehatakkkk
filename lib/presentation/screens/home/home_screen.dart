import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
import 'package:sehatak/presentation/screens/home/tabs/home_tab.dart';
import 'package:sehatak/presentation/widgets/community/doctor_community_fab.dart';
import 'package:sehatak/presentation/widgets/common/custom_bottom_navigation_bar.dart';
class ScreenKeys{static const home=ValueKey('home_tab'),doctors=ValueKey('doctors_tab'),pharmacy=ValueKey('pharmacy_tab'),chat=ValueKey('chat_tab'),labs=ValueKey('labs_tab'),patient=ValueKey('patient_tab'),more=ValueKey('more_tab');}
class HomeScreen extends StatefulWidget{const HomeScreen({super.key});@override State<HomeScreen> createState()=>_HomeScreenState();}
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
 int _currentIndex=0;final _scrollController=ScrollController();late final GlobalScrollManager _scrollManager;bool _isLoggedIn=false,_backPressedOnce=false;Timer? _backExitTimer;late final Map<int,Widget> _screens;
 @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);_scrollManager=GlobalScrollManager();_screens={0:HomeTab(key:ScreenKeys.home,scrollController:_scrollController),1:const DoctorsListScreen(key:ScreenKeys.doctors),2:const PharmacyScreen(key:ScreenKeys.pharmacy),3:const ChatScreen(key:ScreenKeys.chat),4:const LabsListScreen(key:ScreenKeys.labs),5:const RoleBasedDashboardScreen(key:ScreenKeys.patient),6:const MoreScreen(key:ScreenKeys.more)};_checkAuth();_systemNav();}
 void _systemNav(){SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor:Colors.transparent,systemNavigationBarDividerColor:Colors.transparent,systemNavigationBarIconBrightness:Brightness.dark,statusBarIconBrightness:Brightness.dark));}
 void _checkAuth(){final v=FirebaseAuth.instance.currentUser!=null;if(mounted&&v!=_isLoggedIn)setState(()=>_isLoggedIn=v);}
 @override void dispose(){_backExitTimer?.cancel();_scrollController.dispose();_scrollManager.dispose();WidgetsBinding.instance.removeObserver(this);super.dispose();}
 @override void didChangeAppLifecycleState(AppLifecycleState s){if(s==AppLifecycleState.resumed){_checkAuth();_systemNav();}}
 bool _scroll(ScrollNotification n){if(n.metrics.axis!=Axis.vertical)return false;if(n is UserScrollNotification){if(n.direction==ScrollDirection.reverse)_scrollManager.handleScrollDelta(6);else if(n.direction==ScrollDirection.forward)_scrollManager.handleScrollDelta(-6);}else if(n is ScrollEndNotification&&n.metrics.pixels<=n.metrics.minScrollExtent+2)_scrollManager.show();return false;}
 void _back(){if(_currentIndex!=0){setState(()=>_currentIndex=0);_scrollManager.show();return;}if(_backPressedOnce){_backPressedOnce=false;_backExitTimer?.cancel();SystemNavigator.pop();return;}_backPressedOnce=true;ToastService.showInfo('اضغط مرة أخرى للخروج من التطبيق');_backExitTimer?.cancel();_backExitTimer=Timer(const Duration(seconds:2),(){if(mounted)setState(()=>_backPressedOnce=false);});}
 void _tab(int i){if(!_isLoggedIn&&FirebaseAuth.instance.currentUser!=null)_checkAuth();final logged=FirebaseAuth.instance.currentUser!=null;if((i==3||i==4||i==5)&&!logged){_auth();return;}_scrollManager.show();if(_currentIndex!=i)setState(()=>_currentIndex=i);HapticFeedback.lightImpact();}
 void _auth(){if(FirebaseAuth.instance.currentUser!=null){_checkAuth();return;}Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const AuthScreen())).then((_)=>_checkAuth());}
 @override Widget build(BuildContext context){final dark=Theme.of(context).brightness==Brightness.dark;return PopScope(canPop:false,onPopInvoked:(didPop){if(!didPop)_back();},child:Scaffold(extendBody:true,backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF8FAFC),body:Stack(children:[NotificationListener<ScrollNotification>(onNotification:_scroll,child:IndexedStack(index:_currentIndex,children:_screens.values.toList(growable:false))),if(_currentIndex==0)PositionedDirectional(end:18,bottom:92,child:DoctorCommunityFab(scrollController:_scrollController,dark:dark))]),bottomNavigationBar:AnimatedBuilder(animation:_scrollManager,builder:(_,__)=>_AnimatedBottomNavigationBar(visible:_scrollManager.isVisible,child:CustomBottomNavigationBar(currentIndex:_currentIndex,onTap:_tab,scrollController:_scrollController,scrollManager:_scrollManager,isLoggedIn:_isLoggedIn,onAuthRequired:_auth)))));}
}
class _AnimatedBottomNavigationBar extends StatelessWidget{final bool visible;final Widget child;const _AnimatedBottomNavigationBar({required this.visible,required this.child});@override Widget build(BuildContext context)=>AnimatedSize(duration:const Duration(milliseconds:220),curve:Curves.easeOutCubic,alignment:Alignment.topCenter,child:AnimatedOpacity(duration:const Duration(milliseconds:160),opacity:visible?1:0,child:Align(alignment:Alignment.topCenter,heightFactor:visible?1:0,child:child)));}
