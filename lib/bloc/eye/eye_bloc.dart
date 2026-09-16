import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/eye/eye_event.dart';
import 'package:sehatak/bloc/eye/eye_state.dart';
import 'package:sehatak/core/models/eye/eye_models.dart';
import 'package:sehatak/core/services/eye_service.dart';
class EyeBloc extends Bloc<EyeEvent,EyeState>{final EyeService _service;final List<StreamSubscription<dynamic>> _subscriptions=[];String? _specialty;EyeBloc({EyeService? service}):_service=service??EyeService(),super(const EyeState()){on<EyeStarted>((e,emit)=>_subscribe(emit));on<EyeRefreshed>((e,emit)=>_subscribe(emit));on<EyeFilterBySpecialty>((e,emit){_specialty=e.specialty;_subscribe(emit);});on<_DoctorsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,doctors:e.data)));on<_ClinicsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,clinics:e.data)));on<_TipsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,tips:e.data)));on<_HospitalsUpdated>((e,emit)=>emit(state.copyWith(isLoading:false,hospitals:e.data)));}
Future<void> _subscribe(Emitter<EyeState> emit)async{await _cancel();emit(state.copyWith(isLoading:true,clearError:true));try{_subscriptions.add(_service.streamDoctors(specialty:_specialty).listen((v)=>add(_DoctorsUpdated(v))));_subscriptions.add(_service.streamClinics().listen((v)=>add(_ClinicsUpdated(v))));_subscriptions.add(_service.streamTips().listen((v)=>add(_TipsUpdated(v))));_subscriptions.add(_service.streamHospitals().listen((v)=>add(_HospitalsUpdated(v))));}catch(e){emit(state.copyWith(isLoading:false,errorMessage:'تعذر تحميل صحة العين: $e'));}}
Future<void> _cancel()async{for(final s in _subscriptions){await s.cancel();}_subscriptions.clear();}@override Future<void> close()async{await _cancel();return super.close();}}
class _DoctorsUpdated extends EyeEvent{final List<EyeDoctor> data;const _DoctorsUpdated(this.data);@override List<Object?>get props=>[data];}
class _ClinicsUpdated extends EyeEvent{final List<EyeClinic> data;const _ClinicsUpdated(this.data);@override List<Object?>get props=>[data];}
class _TipsUpdated extends EyeEvent{final List<EyeTip> data;const _TipsUpdated(this.data);@override List<Object?>get props=>[data];}
class _HospitalsUpdated extends EyeEvent{final List<EyeHospital> data;const _HospitalsUpdated(this.data);@override List<Object?>get props=>[data];}
