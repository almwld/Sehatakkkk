import 'package:equatable/equatable.dart';
abstract class EyeEvent extends Equatable { const EyeEvent(); @override List<Object?> get props => []; }
class EyeStarted extends EyeEvent { const EyeStarted(); }
class EyeRefreshed extends EyeEvent { const EyeRefreshed(); }
class EyeFilterBySpecialty extends EyeEvent { final String? specialty; const EyeFilterBySpecialty(this.specialty); @override List<Object?> get props => [specialty]; }
