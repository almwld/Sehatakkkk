import 'package:flutter_bloc/flutter_bloc.dart';

// ✅ DoctorBloc - إدارة حالة الأطباء
class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  DoctorBloc() : super(DoctorInitial()) {
    on<DoctorsLoaded>((event, emit) => emit(DoctorsLoadedState()));
  }
}

// ✅ الأحداث
abstract class DoctorEvent {}
class DoctorsLoaded extends DoctorEvent {}

// ✅ الحالات
abstract class DoctorState {}
class DoctorInitial extends DoctorState {}
class DoctorsLoadedState extends DoctorState {}
