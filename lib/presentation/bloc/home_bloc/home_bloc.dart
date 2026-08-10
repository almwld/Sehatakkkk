import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/presentation/bloc/home_bloc/home_event.dart';
import 'package:sehatak/presentation/bloc/home_bloc/home_state.dart';
import 'package:sehatak/data/repositories/home_data_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>(_onLoad);
    on<RefreshHomeData>(_onRefresh);
    on<ToggleLikeEvent>(_onToggleLike);
    on<UpdateHealthScore>(_onUpdateHealthScore);
  }

  Future<void> _onLoad(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.loading());
    try {
      final data = await _fetchAllData();
      emit(state.success(
        doctors: data.doctors,
        products: data.products,
        hospitals: data.hospitals,
        labs: data.labs,
        pharmacies: data.pharmacies,
        articles: data.articles,
        posts: data.posts,
        healthScore: data.healthScore,
      ));
    } catch (e) {
      emit(state.error(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshHomeData event, Emitter<HomeState> emit) async {
    emit(state.refreshing());
    try {
      final data = await _fetchAllData();
      emit(state.success(
        doctors: data.doctors,
        products: data.products,
        hospitals: data.hospitals,
        labs: data.labs,
        pharmacies: data.pharmacies,
        articles: data.articles,
        posts: data.posts,
        healthScore: data.healthScore,
      ));
    } catch (e) {
      emit(state.error(e.toString()));
    }
  }

  void _onToggleLike(ToggleLikeEvent event, Emitter<HomeState> emit) {
    final posts = state.posts.map((post) {
      if (post.id == event.postId) {
        post.liked = !post.liked;
        post.likes += post.liked ? 1 : -1;
      }
      return post;
    }).toList();
    emit(state.copyWith(posts: posts));
  }

  void _onUpdateHealthScore(UpdateHealthScore event, Emitter<HomeState> emit) {
    emit(state.copyWith(healthScore: event.score));
  }

  Future<HomeData> _fetchAllData() async {
    return HomeData(
      doctors: HomeDataRepository.getTopDoctors(),
      products: HomeDataRepository.getProducts(),
      hospitals: HomeDataRepository.getFeaturedHospitals(),
      labs: HomeDataRepository.getFeaturedLabs(),
      pharmacies: HomeDataRepository.getFeaturedPharmacies(),
      articles: HomeDataRepository.getArticles(),
      posts: HomeDataRepository.getCommunityPosts(),
      healthScore: 75.0,
    );
  }
}

class HomeData {
  final List<DoctorModel> doctors;
  final List<ProductModel> products;
  final List<HospitalModel> hospitals;
  final List<LabModel> labs;
  final List<PharmacyModel> pharmacies;
  final List<ArticleModel> articles;
  final List<CommunityPostModel> posts;
  final double healthScore;

  HomeData({
    required this.doctors,
    required this.products,
    required this.hospitals,
    required this.labs,
    required this.pharmacies,
    required this.articles,
    required this.posts,
    required this.healthScore,
  });
}
