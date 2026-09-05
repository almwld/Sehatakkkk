import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/doctor_model.dart';

// ============================================================
// 📋 الأحداث (Events)
// ============================================================
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
class FilterDoctorsBySpecialty extends DoctorEvent {
  final String specialty;
  const FilterDoctorsBySpecialty({required this.specialty});
  @override
  List<Object?> get props => [specialty];
}

// ============================================================
// 📊 الحالات (States)
// ============================================================
abstract class DoctorState extends Equatable {
  const DoctorState();
  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}
class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  final List<DoctorModel> filteredDoctors;
  final String? searchQuery;
  final String? selectedSpecialty;

  const DoctorLoaded({
    required this.doctors,
    this.filteredDoctors = const [],
    this.searchQuery,
    this.selectedSpecialty,
  });

  @override
  List<Object?> get props => [doctors, filteredDoctors, searchQuery, selectedSpecialty];

  List<DoctorModel> get displayDoctors {
    return filteredDoctors.isNotEmpty ? filteredDoctors : doctors;
  }
}

class DoctorError extends DoctorState {
  final String message;
  const DoctorError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ============================================================
// 🧠 BLoC
// ============================================================
class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DoctorModel> _allDoctors = [];

  DoctorBloc() : super(DoctorInitial()) {
    on<LoadDoctors>(_onLoadDoctors);
    on<RefreshDoctors>(_onRefreshDoctors);
    on<SearchDoctors>(_onSearchDoctors);
    on<FilterDoctorsBySpecialty>(_onFilterDoctorsBySpecialty);
  }

  // ✅ تحميل الأطباء من Firestore
  Future<void> _onLoadDoctors(LoadDoctors event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .where('isAvailable', isEqualTo: true)
          .get();

      _allDoctors = snapshot.docs.map((doc) {
        return DoctorModel.fromFirestore(doc.id, doc.data());
      }).toList();

      emit(DoctorLoaded(
        doctors: _allDoctors,
        filteredDoctors: _allDoctors,
      ));
    } catch (e) {
      emit(DoctorError(message: 'حدث خطأ: ${e.toString()}'));
    }
  }

  // ✅ تحديث الأطباء
  Future<void> _onRefreshDoctors(RefreshDoctors event, Emitter<DoctorState> emit) async {
    add(LoadDoctors());
  }

  // ✅ البحث عن الأطباء
  void _onSearchDoctors(SearchDoctors event, Emitter<DoctorState> emit) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;
      final query = event.query.toLowerCase().trim();

      if (query.isEmpty) {
        emit(DoctorLoaded(
          doctors: currentState.doctors,
          filteredDoctors: currentState.doctors,
          searchQuery: null,
        ));
        return;
      }

      final filtered = currentState.doctors.where((doctor) {
        final name = doctor.name.toLowerCase();
        final specialty = doctor.specialty.toLowerCase();
        return name.contains(query) || specialty.contains(query);
      }).toList();

      emit(DoctorLoaded(
        doctors: currentState.doctors,
        filteredDoctors: filtered,
        searchQuery: query,
      ));
    }
  }

  // ✅ فلترة الأطباء حسب التخصص
  void _onFilterDoctorsBySpecialty(FilterDoctorsBySpecialty event, Emitter<DoctorState> emit) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;

      if (event.specialty == 'الكل') {
        emit(DoctorLoaded(
          doctors: currentState.doctors,
          filteredDoctors: currentState.doctors,
          selectedSpecialty: null,
        ));
        return;
      }

      final filtered = currentState.doctors.where((doctor) {
        return doctor.specialty == event.specialty;
      }).toList();

      emit(DoctorLoaded(
        doctors: currentState.doctors,
        filteredDoctors: filtered,
        selectedSpecialty: event.specialty,
      ));
    }
  }
}
