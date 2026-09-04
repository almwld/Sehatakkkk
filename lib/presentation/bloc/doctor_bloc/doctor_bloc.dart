import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// نموذج مبسط للطبيب
class SimpleDoctor {
  final String id;
  final String name;
  final String specialty;
  final String? hospital;
  final double? rating;
  final String? photoUrl;

  SimpleDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.hospital,
    this.rating,
    this.photoUrl,
  });

  factory SimpleDoctor.fromFirestore(String id, Map<String, dynamic> data) {
    return SimpleDoctor(
      id: id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      hospital: data['hospital'],
      rating: (data['rating'] as num?)?.toDouble(),
      photoUrl: data['photoUrl'],
    );
  }
}

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
  final List<SimpleDoctor> doctors;
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
        return SimpleDoctor.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      emit(DoctorLoaded(doctors: doctors));
    } catch (e) {
      emit(DoctorError(message: 'حدث خطأ: ${e.toString()}'));
    }
  }
}
