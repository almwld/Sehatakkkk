// ============================================================
// 📁 lib/bloc/home/home_state.dart
// 📊 حالة Home
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:sehatak/core/models/hospital/hospital_model.dart';
import 'package:sehatak/core/models/pharmacy/pharmacy_model.dart';
import 'package:sehatak/core/models/lab/lab_model.dart';
import 'package:sehatak/core/models/article/article_model.dart';
import 'package:sehatak/core/models/tip/tip_model.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';

enum HomeStatus { initial, loading, loaded, error, refreshing }

class HomeState extends Equatable {
  final HomeStatus status;
  final String? errorMessage;
  final bool isLoggedIn;
  final String userName;
  final List<String> bannerImages;
  final int currentBanner;
  final double calories;
  final double steps;
  final double sleep;
  final double heartRate;
  final List<Map<String, dynamic>> doctors;
  final List<Map<String, dynamic>> hospitals;
  final List<Map<String, dynamic>> pharmacies;
  final List<Map<String, dynamic>> labs;
  final List<Map<String, dynamic>> articles;
  final List<Map<String, dynamic>> tips;
  final List<Map<String, dynamic>> communityPosts;
  final int notificationCount;
  final double appBarOpacity;
  final bool showScrollTopButton;

  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
    this.isLoggedIn = false,
    this.userName = 'مستخدم',
    this.bannerImages = const [],
    this.currentBanner = 0,
    this.calories = 0,
    this.steps = 0,
    this.sleep = 0,
    this.heartRate = 0,
    this.doctors = const [],
    this.hospitals = const [],
    this.pharmacies = const [],
    this.labs = const [],
    this.articles = const [],
    this.tips = const [],
    this.communityPosts = const [],
    this.notificationCount = 0,
    this.appBarOpacity = 1.0,
    this.showScrollTopButton = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    bool? isLoggedIn,
    String? userName,
    List<String>? bannerImages,
    int? currentBanner,
    double? calories,
    double? steps,
    double? sleep,
    double? heartRate,
    List<Map<String, dynamic>>? doctors,
    List<Map<String, dynamic>>? hospitals,
    List<Map<String, dynamic>>? pharmacies,
    List<Map<String, dynamic>>? labs,
    List<Map<String, dynamic>>? articles,
    List<Map<String, dynamic>>? tips,
    List<Map<String, dynamic>>? communityPosts,
    int? notificationCount,
    double? appBarOpacity,
    bool? showScrollTopButton,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userName: userName ?? this.userName,
      bannerImages: bannerImages ?? this.bannerImages,
      currentBanner: currentBanner ?? this.currentBanner,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      sleep: sleep ?? this.sleep,
      heartRate: heartRate ?? this.heartRate,
      doctors: doctors ?? this.doctors,
      hospitals: hospitals ?? this.hospitals,
      pharmacies: pharmacies ?? this.pharmacies,
      labs: labs ?? this.labs,
      articles: articles ?? this.articles,
      tips: tips ?? this.tips,
      communityPosts: communityPosts ?? this.communityPosts,
      notificationCount: notificationCount ?? this.notificationCount,
      appBarOpacity: appBarOpacity ?? this.appBarOpacity,
      showScrollTopButton: showScrollTopButton ?? this.showScrollTopButton,
    );
  }

  bool get isLoading => status == HomeStatus.loading;
  bool get isRefreshing => status == HomeStatus.refreshing;
  bool get hasError => status == HomeStatus.error;
  bool get isLoaded => status == HomeStatus.loaded;

  @override
  List<Object?> get props => [status, isLoggedIn, userName, doctors, hospitals];
}
