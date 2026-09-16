import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/dental/dental_event.dart';
import 'package:sehatak/bloc/dental/dental_state.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';
import 'package:sehatak/core/services/dental_service.dart';
class DentalBloc extends Bloc<DentalEvent,DentalState>{final DentalService _service; final List<StreamSubscription<dynamic>> _subscriptions=[]; String? _specialty; DentalBloc({DentalService? service}):_service=service??DentalService(),super(const DentalState()){on<DentalStarted>((e,emit)=>_subscribe(emit));on<DentalRefreshed>((e,emit)=>_subscribe(emit));on<DentalFilterBySpecialty>((e,emit){_specialty=e.specialty;_subscribe(emit);});on<_DoctorsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,doctors:e.data)));on<_ClinicsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,clinics:e.data)));on<_TipsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,tips:e.data)));on<_HospitalsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,hospitals:e.data)));}
Future<void> _subscribe(Emitter<DentalState> emit)async{await _cancel();emit(state.copyWith(isLoading:true,clearError:true));try{_subscriptions.add(_service.streamDoctors(specialty:_specialty).listen((v)=>add(_DoctorsUpdated(v))));_subscriptions.add(_service.streamClinics().listen((v)=>add(_ClinicsUpdated(v))));_subscriptions.add(_service.streamTips().listen((v)=>add(_TipsUpdated(v))));_subscriptions.add(_service.streamHospitals().listen((v)=>add(_HospitalsUpdated(v))));}catch(e){emit(state.copyWith(isLoading:false,errorMessage:'تعذر تحميل صحة الأسنان: $e'));}}
Future<void> _cancel()async{for(final s in _subscriptions){await s.cancel();}_subscriptions.clear();}@override Future<void> close()async{await _cancel();return super.close();}}
class _DoctorsUpdated extends DentalEvent{final List<DentalDoctor> data;const _DoctorsUpdated(this.data);@override List<Object?>get props=>[data];}
class _ClinicsUpdated extends DentalEvent{final List<DentalClinic> data;const _ClinicsUpdated(this.data);@override List<Object?>get props=>[data];}
class _TipsUpdated extends DentalEvent{final List<DentalTip> data;const _TipsUpdated(this.data);@override List<Object?>get props=>[data];}
class _HospitalsUpdated extends DentalEvent{final List<DentalHospital> data;const _HospitalsUpdated(this.data);@override List<Object?>get props=>[data];}
