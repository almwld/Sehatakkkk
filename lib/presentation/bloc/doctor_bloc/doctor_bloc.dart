import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:sehatak/core/models/doctor_model.dart';

// Events
abstract class DoctorEvent extends Equatable {
  const DoctorEvent();
  @override
  List<Object?> get props => [];
}

class LoadDoctors extends DoctorEvent {}

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
}
