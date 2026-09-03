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
class LoadDoctorDetails extends DoctorEvent {
  final String doctorId;
  const LoadDoctorDetails({required this.doctorId});
  @override
  List<Object?> get props => [doctorId];
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

class DoctorDetailsLoaded extends DoctorState {
  final DoctorModel doctor;
  const DoctorDetailsLoaded({required this.doctor});
  @override
  List<Object?> get props => [doctor];
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
    on<LoadDoctorDetails>(_onLoadDoctorDetails);
  }

  Future<void> _onLoadDoctors(LoadDoctors event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    try {
      final snapshot = await _firestore.collection('doctors').get();
      final doctors = snapshot.docs.map((doc) {
        return DoctorModel.fromFirestore(doc.id, doc.data());
      }).toList();
      emit(DoctorLoaded(doctors: doctors));
    } catch (e) {
      emit(DoctorError(message: e.toString()));
    }
  }

  Future<void> _onLoadDoctorDetails(
    LoadDoctorDetails event,
    Emitter<DoctorState> emit,
  ) async {
    emit(DoctorLoading());
    try {
      final doc = await _firestore.collection('doctors').doc(event.doctorId).get();
      if (!doc.exists) {
        emit(DoctorError(message: 'الطبيب غير موجود'));
        return;
      }
      final doctor = DoctorModel.fromFirestore(doc.id, doc.data());
      emit(DoctorDetailsLoaded(doctor: doctor));
    } catch (e) {
      emit(DoctorError(message: e.toString()));
    }
  }
}
