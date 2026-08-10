import 'package:sehatak/data/models/doctor_model.dart';
import 'package:sehatak/data/models/product_model.dart';
import 'package:sehatak/data/models/hospital_model.dart';
import 'package:sehatak/data/models/lab_model.dart';
import 'package:sehatak/data/models/pharmacy_model.dart';
import 'package:sehatak/data/models/article_model.dart';
import 'package:sehatak/data/models/community_post_model.dart';

class HomeState {
  final bool isLoading;
  final bool isRefreshing;
  final bool hasError;
  final String? errorMessage;
  final List<DoctorModel> doctors;
  final List<ProductModel> products;
  final List<HospitalModel> hospitals;
  final List<LabModel> labs;
  final List<PharmacyModel> pharmacies;
  final List<ArticleModel> articles;
  final List<CommunityPostModel> posts;
  final double healthScore;

  const HomeState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasError = false,
    this.errorMessage,
    this.doctors = const [],
    this.products = const [],
    this.hospitals = const [],
    this.labs = const [],
    this.pharmacies = const [],
    this.articles = const [],
    this.posts = const [],
    this.healthScore = 0.0,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? hasError,
    String? errorMessage,
    List<DoctorModel>? doctors,
    List<ProductModel>? products,
    List<HospitalModel>? hospitals,
    List<LabModel>? labs,
    List<PharmacyModel>? pharmacies,
    List<ArticleModel>? articles,
    List<CommunityPostModel>? posts,
    double? healthScore,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      doctors: doctors ?? this.doctors,
      products: products ?? this.products,
      hospitals: hospitals ?? this.hospitals,
      labs: labs ?? this.labs,
      pharmacies: pharmacies ?? this.pharmacies,
      articles: articles ?? this.articles,
      posts: posts ?? this.posts,
      healthScore: healthScore ?? this.healthScore,
    );
  }

  HomeState loading() => copyWith(isLoading: true, hasError: false);
  HomeState refreshing() => copyWith(isRefreshing: true);
  HomeState success({
    List<DoctorModel>? doctors,
    List<ProductModel>? products,
    List<HospitalModel>? hospitals,
    List<LabModel>? labs,
    List<PharmacyModel>? pharmacies,
    List<ArticleModel>? articles,
    List<CommunityPostModel>? posts,
    double? healthScore,
  }) =>
      copyWith(
        isLoading: false,
        isRefreshing: false,
        hasError: false,
        errorMessage: null,
        doctors: doctors ?? this.doctors,
        products: products ?? this.products,
        hospitals: hospitals ?? this.hospitals,
        labs: labs ?? this.labs,
        pharmacies: pharmacies ?? this.pharmacies,
        articles: articles ?? this.articles,
        posts: posts ?? this.posts,
        healthScore: healthScore ?? this.healthScore,
      );
  HomeState error(String message) => copyWith(
        isLoading: false,
        isRefreshing: false,
        hasError: true,
        errorMessage: message,
      );
}
