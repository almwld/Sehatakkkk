import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/services/firestore_service.dart';

// ========== EVENTS ==========
abstract class DoctorEvent {}
class LoadDoctors extends DoctorEvent {}
class LoadDoctorDetails extends DoctorEvent {
  final String doctorId;
  LoadDoctorDetails(this.doctorId);
}

// ========== STATES ==========
abstract class DoctorState {}
class DoctorInitial extends DoctorState {}
class DoctorLoading extends DoctorState {}
class DoctorLoadedState extends DoctorState {
  final List<Map<String, dynamic>> doctors;
  DoctorLoadedState(this.doctors);
}
class DoctorDetailsLoadedState extends DoctorState {
  final Map<String, dynamic> doctor;
  DoctorDetailsLoadedState(this.doctor);
}
class DoctorErrorState extends DoctorState {
  final String message;
  DoctorErrorState(this.message);
}

// ========== BLOC ==========
class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final FirestoreService _firestore = FirestoreService();

  DoctorBloc() : super(DoctorInitial()) {
    on<LoadDoctors>(_onLoadDoctors);
    on<LoadDoctorDetails>(_onLoadDoctorDetails);
  }

  Future<void> _onLoadDoctors(LoadDoctors event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    try {
      final doctors = await _firestore.getDoctors().first;
      emit(DoctorLoadedState(doctors));
    } catch (e) {
      emit(DoctorErrorState('فشل تحميل الأطباء: $e'));
    }
  }

  Future<void> _onLoadDoctorDetails(LoadDoctorDetails event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    try {
      final doctor = await _firestore.getDoctor(event.doctorId);
      if (doctor != null) {
        emit(DoctorDetailsLoadedState(doctor));
      } else {
        emit(DoctorErrorState('الطبيب غير موجود'));
      }
    } catch (e) {
      emit(DoctorErrorState('فشل تحميل تفاصيل الطبيب: $e'));
    }
  }
}
