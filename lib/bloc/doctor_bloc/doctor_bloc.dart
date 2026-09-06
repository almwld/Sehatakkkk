import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/core/models/doctor_model.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctors extends DoctorEvent {
  final String specialty;

  const LoadDoctors({
    this.specialty = 'الكل',
  });

  @override
  List<Object?> get props => [specialty];
}

class RefreshDoctors extends DoctorEvent {
  const RefreshDoctors();
}

class SearchDoctors extends DoctorEvent {
  final String query;

  const SearchDoctors({
    required this.query,
  });

  @override
  List<Object?> get props => [query];
}

class FilterDoctors extends DoctorEvent {
  final String specialty;

  const FilterDoctors({
    required this.specialty,
  });

  @override
  List<Object?> get props => [specialty];
}

abstract class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {
  const DoctorInitial();
}

class DoctorLoading extends DoctorState {
  const DoctorLoading();
}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;

  const DoctorLoaded({
    required this.doctors,
  });

  @override
  List<Object?> get props => [doctors];
}

class DoctorError extends DoctorState {
  final String message;

  const DoctorError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  List<DoctorModel> _allDoctors = [];

  String _searchQuery = '';
  String _selectedSpecialty = 'الكل';

  DoctorBloc() : super(const DoctorInitial()) {
    on<LoadDoctors>(_onLoadDoctors);
    on<RefreshDoctors>(_onRefreshDoctors);
    on<SearchDoctors>(_onSearchDoctors);
    on<FilterDoctors>(_onFilterDoctors);
  }

  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) {
      return null;
    }

    return FirebaseFirestore.instance;
  }

  Future<void> _onLoadDoctors(
    LoadDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    _selectedSpecialty = event.specialty;
    _searchQuery = '';

    emit(const DoctorLoading());

    await _fetchDoctors(emit);
  }

  Future<void> _onRefreshDoctors(
    RefreshDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    if (_firestore == null) {
      emit(
        const DoctorError(
          message: 'الخدمة غير جاهزة بعد، حاول مرة أخرى.',
        ),
      );
      return;
    }

    await _fetchDoctors(
      emit,
      showLoading: false,
    );
  }

  Future<void> _onSearchDoctors(
    SearchDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    _searchQuery = event.query.trim();

    emit(
      DoctorLoaded(
        doctors: _applyFilters(),
      ),
    );
  }

  Future<void> _onFilterDoctors(
    FilterDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    _selectedSpecialty = event.specialty;

    emit(
      DoctorLoaded(
        doctors: _applyFilters(),
      ),
    );
  }

  Future<void> _fetchDoctors(
    Emitter<DoctorState> emit, {
    bool showLoading = true,
  }) async {
    final firestore = _firestore;

    if (firestore == null) {
      emit(
        const DoctorError(
          message: 'خدمة الأطباء غير جاهزة بعد.',
        ),
      );
      return;
    }

    try {
      Query<Map<String, dynamic>> query = firestore
          .collection('doctors')
          .where('isVerified', isEqualTo: true);

      final snapshot = await query.get();

      _allDoctors = snapshot.docs
          .map(
            (doc) => DoctorModel.fromFirestore(
              doc.id,
              doc.data(),
            ),
          )
          .where(
            (doctor) =>
                doctor.name.trim().isNotEmpty &&
                doctor.specialty.trim().isNotEmpty,
          )
          .toList();

      _allDoctors.sort((a, b) {
        final aFeatured = a.isFeatured ? 0 : 1;
        final bFeatured = b.isFeatured ? 0 : 1;

        if (aFeatured != bFeatured) {
          return aFeatured.compareTo(bFeatured);
        }

        final aRating = a.rating ?? 0;
        final bRating = b.rating ?? 0;

        return bRating.compareTo(aRating);
      });

      emit(
        DoctorLoaded(
          doctors: _applyFilters(),
        ),
      );
    } catch (e) {
      emit(
        DoctorError(
          message: 'تعذر تحميل الأطباء: $e',
        ),
      );
    }
  }

  List<DoctorModel> _applyFilters() {
    Iterable<DoctorModel> result = _allDoctors;

    final specialty = _selectedSpecialty.trim();

    if (specialty.isNotEmpty && specialty != 'الكل') {
      final normalizedSpecialty = specialty.toLowerCase();

      result = result.where((doctor) {
        final mainSpecialty = doctor.specialty.toLowerCase();

        final subspecialty =
            (doctor.subspecialty ?? '').toLowerCase();

        final specialties = (doctor.specialties ?? const <String>[])
            .map((item) => item.toLowerCase());

        return mainSpecialty.contains(normalizedSpecialty) ||
            normalizedSpecialty.contains(mainSpecialty) ||
            subspecialty.contains(normalizedSpecialty) ||
            specialties.any(
              (item) =>
                  item.contains(normalizedSpecialty) ||
                  normalizedSpecialty.contains(item),
            );
      });
    }

    final query = _searchQuery.toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((doctor) {
        final name = doctor.name.toLowerCase();
        final specialtyName = doctor.specialty.toLowerCase();
        final subspecialty =
            (doctor.subspecialty ?? '').toLowerCase();
        final hospital =
            (doctor.hospital ?? '').toLowerCase();

        return name.contains(query) ||
            specialtyName.contains(query) ||
            subspecialty.contains(query) ||
            hospital.contains(query);
      });
    }

    return result.toList();
  }

  @override
  Future<void> close() {
    _allDoctors = [];
    return super.close();
  }
}
