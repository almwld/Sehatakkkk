import 'package:equatable/equatable.dart';
import 'package:sehatak/data/models/doctor_model.dart';
import 'package:sehatak/data/models/product_model.dart';
import 'package:sehatak/data/models/hospital_model.dart';
import 'package:sehatak/data/models/lab_model.dart';
import 'package:sehatak/data/models/pharmacy_model.dart';
import 'package:sehatak/data/models/article_model.dart';
import 'package:sehatak/data/models/community_post_model.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final bool hasError;
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
    this.doctors = const [],
    this.products = const [],
    this.hospitals = const [],
    this.labs = const [],
    this.pharmacies = const [],
    this.articles = const [],
    this.posts = const [],
    this.healthScore = 0.0,
  });

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    hasError,
    doctors,
    products,
    hospitals,
    labs,
    pharmacies,
    articles,
    posts,
    healthScore,
  ];
}
