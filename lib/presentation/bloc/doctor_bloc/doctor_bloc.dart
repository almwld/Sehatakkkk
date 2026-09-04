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

class RefreshDoctors extends DoctorEvent {}

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
  }

  Future<void> _onLoadDoctors(
    LoadDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    bool hasCache = false;

    // 1. حاول استخدام Firestore Offline Cache أولًا.
    try {
      final cacheSnapshot = await _firestore
          .collection('doctors')
          .get(
            const GetOptions(source: Source.cache),
          );

      if (cacheSnapshot.docs.isNotEmpty) {
        final doctors = cacheSnapshot.docs.map((doc) {
          return DoctorModel.fromFirestore(
            doc.id,
            doc.data(),
          );
        }).toList();

        if (doctors.isNotEmpty) {
          hasCache = true;
          emit(DoctorLoaded(doctors: doctors));
        }
      }
    } catch (_) {
      // لا توجد Cache، سنحاول الخادم.
    }

    // 2. إذا لم توجد Cache، أظهر Loading.
    if (!hasCache) {
      emit(DoctorLoading());
    }

    // 3. احصل على أحدث البيانات من الخادم.
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .get(
            const GetOptions(source: Source.server),
          );

      final doctors = snapshot.docs.map((doc) {
        return DoctorModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();

      emit(DoctorLoaded(doctors: doctors));
    } catch (e, stackTrace) {
      print('❌ DoctorBloc ERROR: $e');
      print(stackTrace);

      // إذا كانت Cache موجودة، احتفظ بها بدل تحويل الشاشة إلى Error.
      if (!hasCache) {
        emit(
          DoctorError(
            message: 'حدث خطأ: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onRefreshDoctors(
    RefreshDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    final previousState = state;

    try {
      final snapshot = await _firestore
          .collection('doctors')
          .get(
            const GetOptions(source: Source.server),
          );

      final doctors = snapshot.docs.map((doc) {
        return DoctorModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();

      emit(DoctorLoaded(doctors: doctors));
    } catch (e) {
      // لا نفقد البيانات الحالية إذا فشل التحديث.
      if (previousState is DoctorLoaded) {
        emit(previousState);
      } else {
        emit(
          DoctorError(
            message: 'تعذر تحديث قائمة الأطباء: $e',
          ),
        );
      }
    }
  }
}
