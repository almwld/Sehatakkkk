import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/doctor_model.dart';

// Events
abstract class DoctorEvent extends Equatable {
  const DoctorEvent();
  @override
  List<Object?> get props => [];
}

class LoadDoctors extends DoctorEvent {}
class RefreshDoctors extends DoctorEvent {}
class SearchDoctors extends DoctorEvent {
  final String query;
  const SearchDoctors({required this.query});
  @override
  List<Object?> get props => [query];
}

// States
abstract class DoctorState extends Equatable {
  const DoctorState();
  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}
class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  const DoctorLoaded({required this.doctors});
  @override
  List<Object?> get props => [doctors];
}

class DoctorError extends DoctorState {
  final String message;
  const DoctorError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DoctorBloc() : super(DoctorInitial()) {
    on<LoadDoctors>(_onLoadDoctors);
    on<RefreshDoctors>(_onRefreshDoctors);
    on<SearchDoctors>(_onSearchDoctors);
  }

  Future<void> _onLoadDoctors(LoadDoctors event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    try {
      final snapshot = await _firestore.collection('doctors').get();
      final doctors = snapshot.docs.map((doc) {
        return DoctorModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      emit(DoctorLoaded(doctors: doctors));
    } catch (e) {
      emit(DoctorError(message: 'حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDoctors(RefreshDoctors event, Emitter<DoctorState> emit) async {
    add(LoadDoctors());
  }

  Future<void> _onSearchDoctors(SearchDoctors event, Emitter<DoctorState> emit) async {
    if (state is! DoctorLoaded) return;
    final currentState = state as DoctorLoaded;
    final query = event.query.toLowerCase();
    final filtered = currentState.doctors.where((d) =>
      d.name.toLowerCase().contains(query) ||
      d.specialty.toLowerCase().contains(query)
    ).toList();
    emit(DoctorLoaded(doctors: filtered));
  }
}
