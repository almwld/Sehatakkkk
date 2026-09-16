import 'package:equatable/equatable.dart';
abstract class DentalEvent extends Equatable { const DentalEvent(); @override List<Object?> get props => []; }
class DentalStarted extends DentalEvent { const DentalStarted(); }
class DentalRefreshed extends DentalEvent { const DentalRefreshed(); }
class DentalFilterBySpecialty extends DentalEvent { final String? specialty; const DentalFilterBySpecialty(this.specialty); @override List<Object?> get props => [specialty]; }
