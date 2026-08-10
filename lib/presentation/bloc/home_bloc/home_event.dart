abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}
class RefreshHomeData extends HomeEvent {}
class ToggleLikeEvent extends HomeEvent {
  final int postId;
  ToggleLikeEvent(this.postId);
}
class UpdateHealthScore extends HomeEvent {
  final double score;
  UpdateHealthScore(this.score);
}
